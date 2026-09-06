import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/drift/enums.dart';
import 'package:workshop_os/data/repositories/job_repository.dart';
import 'package:workshop_os/data/supabase/sync_worker.dart';

import 'fake_remote_gateway.dart';

void main() {
  late AppDatabase db;
  late FakeRemoteGateway gateway;
  late SyncWorker worker;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    gateway = FakeRemoteGateway();
    worker = SyncWorker(db, gateway);
  });

  tearDown(() async {
    await worker.stop();
    await db.close();
  });

  Future<void> seedRefs() async {
    await db.into(db.customers).insert(CustomersCompanion.insert(
          id: 'c1',
          name: 'Ramesh Kumar',
          phone: '9876543210',
        ));
    await db.into(db.vehicles).insert(VehiclesCompanion.insert(
          numberPlate: 'KA05MJ4821',
          vehicleType: VehicleType.twoWheeler,
          make: 'Honda',
          model: 'Activa 6G',
        ));
  }

  test('create offline -> flush -> pushed and marked synced', () async {
    await seedRefs();
    final repo = JobRepository(db);
    final job = await repo.createJob(
      vehicleNumberPlate: 'KA05MJ4821',
      customerId: 'c1',
      complaints: 'Brake noise',
    );

    var local =
        await (db.select(db.jobCards)..where((j) => j.id.equals(job.id)))
            .getSingle();
    expect(local.synced, false);

    await worker.syncNow();

    expect(
      gateway.upserts.map((u) => u.table),
      containsAll(['customers', 'vehicles', 'job_cards']),
    );
    final pushed = gateway.upserts.firstWhere((u) => u.table == 'job_cards');
    expect(pushed.rows.single['complaints'], 'Brake noise');
    expect(pushed.rows.single['status'], 'Arrived');

    local = await (db.select(db.jobCards)..where((j) => j.id.equals(job.id)))
        .getSingle();
    expect(local.synced, true);
    expect(local.syncedAt, isNotNull);
  });

  test('second sync does not re-push already-synced rows', () async {
    await seedRefs();
    await worker.syncNow();
    final countAfterFirst =
        gateway.upserts.where((u) => u.table == 'customers').length;
    expect(countAfterFirst, greaterThanOrEqualTo(1));

    await worker.syncNow();
    final countAfterSecond =
        gateway.upserts.where((u) => u.table == 'customers').length;
    expect(countAfterSecond, countAfterFirst);
  });

  test('pull applies remote customer into clean local db', () async {
    gateway.store['customers'] = [
      {
        'id': 'remote-1',
        'name': 'Owner Web',
        'phone': '9000000001',
        'created_at': '2026-08-01T10:00:00.000Z',
      }
    ];

    await worker.syncNow();

    final c = await (db.select(db.customers)
          ..where((x) => x.id.equals('remote-1')))
        .getSingleOrNull();
    expect(c, isNotNull);
    expect(c!.name, 'Owner Web');
    expect(c.synced, true);

    // cursor advanced: same remote row is not re-applied next round
    gateway.upserts.clear();
    await worker.syncNow();
    expect(
      gateway.upserts.where((u) => u.table == 'customers'),
      isEmpty,
    );
  });

  test('conflict: newer remote updated_at wins over stale dirty local job',
      () async {
    await seedRefs();
    final repo = JobRepository(db);
    final job = await repo.createJob(
      vehicleNumberPlate: 'KA05MJ4821',
      customerId: 'c1',
      complaints: 'local version',
    );
    final staleLocal =
        await (db.select(db.jobCards)..where((j) => j.id.equals(job.id)))
            .getSingle();
    expect(staleLocal.updatedAt.isBefore(DateTime.now()), true);

    final remoteUpdatedAt =
        DateTime.now().toUtc().add(const Duration(minutes: 5));
    gateway.store['job_cards'] = [
      {
        'id': job.id,
        'job_no': staleLocal.jobNo + 100,
        'vehicle_number_plate': 'KA05MJ4821',
        'customer_id': 'c1',
        'km_reading': null,
        'complaints': 'remote version wins',
        'status': 'InProgress',
        'closed': false,
        'notes': null,
        'created_by': null,
        'created_at':
            staleLocal.createdAt.toUtc().toIso8601String(),
        'updated_at': remoteUpdatedAt.toIso8601String(),
      }
    ];

    await worker.syncNow();

    final merged =
        await (db.select(db.jobCards)..where((j) => j.id.equals(job.id)))
            .getSingle();
    expect(merged.complaints, 'remote version wins');
    expect(merged.status, JobStatus.inProgress);
    expect(merged.jobNo, staleLocal.jobNo + 100);
    expect(merged.synced, true);
  });

  test('conflict: newer dirty local updated_at survives the pull', () async {
    await seedRefs();
    final repo = JobRepository(db);
    final job = await repo.createJob(
      vehicleNumberPlate: 'KA05MJ4821',
      customerId: 'c1',
      complaints: 'fresh local edit',
    );
    await repo.updateNotes(job.id, 'edited just now');

    final local =
        await (db.select(db.jobCards)..where((j) => j.id.equals(job.id)))
            .getSingle();

    gateway.store['job_cards'] = [
      {
        'id': job.id,
        'job_no': local.jobNo,
        'vehicle_number_plate': 'KA05MJ4821',
        'customer_id': 'c1',
        'km_reading': null,
        'complaints': 'stale remote copy',
        'status': 'Arrived',
        'closed': false,
        'notes': null,
        'created_by': null,
        'created_at': local.createdAt.toUtc().toIso8601String(),
        'updated_at': local.updatedAt
            .toUtc()
            .subtract(const Duration(hours: 1))
            .toIso8601String(),
      }
    ];

    await worker.syncNow();

    final kept =
        await (db.select(db.jobCards)..where((j) => j.id.equals(job.id)))
            .getSingle();
    expect(kept.complaints, 'fresh local edit');
    expect(kept.notes, 'edited just now');

    // stale remote never overwrote the newer local row; the flush then
    // pushed the LOCAL version upstream
    final pushed = gateway.upserts.lastWhere((u) => u.table == 'job_cards');
    expect(pushed.rows.single['complaints'], 'fresh local edit');
    expect(pushed.rows.single['notes'], 'edited just now');
    expect(kept.synced, true, reason: 'flushed during the same cycle');
  });
}
