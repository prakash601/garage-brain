import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/drift/enums.dart';
import 'package:workshop_os/data/repositories/job_repository.dart';
import 'package:workshop_os/data/supabase/sync_worker.dart';
import 'package:workshop_os/features/create_job/create_job_service.dart';

import 'fake_remote_gateway.dart';

/// End-to-end proof of the sync contract (DESIGN.md §7), played with two
/// real Drift databases against one shared remote:
///
/// device A (receptionist, Android, offline) -> online sync -> device B
/// (owner, Web) sees the job -> owner advances the status -> device A
/// sees the update.
///
/// No UI or emulator is involved: both devices run the production
/// repositories, [CreateJobService], and [SyncWorker]; only the transport
/// ([FakeRemoteGateway]) stands in for Supabase. The manual on-device
/// script for the portfolio demo video lives in `app/README.md`.
void main() {
  late AppDatabase deviceA;
  late AppDatabase deviceB;
  late FakeRemoteGateway cloud;
  late SyncWorker workerA;
  late SyncWorker workerB;

  setUp(() {
    deviceA = AppDatabase(NativeDatabase.memory());
    deviceB = AppDatabase(NativeDatabase.memory());
    cloud = FakeRemoteGateway();
    workerA = SyncWorker(deviceA, cloud);
    workerB = SyncWorker(deviceB, cloud);
  });

  tearDown(() async {
    await workerA.stop();
    await workerB.stop();
    await deviceA.close();
    await deviceB.close();
  });

  test('offline create on A -> sync -> visible on B -> owner edit returns to A',
      () async {
    // 1. OFFLINE on A: full S4 flow, no sync call at all.
    final job = await CreateJobService(deviceA).createJob(
      plate: 'KA05MJ4821',
      vehicleType: VehicleType.twoWheeler,
      make: 'Honda',
      model: 'Activa 6G',
      name: 'Ramesh Kumar',
      phone: '9876543210',
      complaints: 'Brake noise',
    );

    final aCustomer =
        await (deviceA.select(deviceA.customers)).getSingle();
    final aVehicle = await (deviceA.select(deviceA.vehicles)).getSingle();
    final aJob = await (deviceA.select(deviceA.jobCards)
          ..where((j) => j.id.equals(job.id)))
        .getSingle();
    expect(aCustomer.synced, false);
    expect(aVehicle.synced, false);
    expect(aJob.synced, false);

    // Nothing leaked anywhere without sync: the cloud is empty and a
    // fresh device B (owner Web before opening the app) sees nothing.
    expect(cloud.store, isEmpty);
    expect(await deviceB.select(deviceB.jobCards).get(), isEmpty);

    // 2. ONLINE on A: reconnect flush (app start / connectivity trigger).
    await workerA.syncNow();
    expect(workerA.lastError, isNull);
    expect(
      cloud.upserts.map((u) => u.table),
      containsAll(['customers', 'vehicles', 'job_cards']),
    );
    for (final id in [aCustomer.id]) {
      final row = await (deviceA.select(deviceA.customers)
            ..where((c) => c.id.equals(id)))
          .getSingle();
      expect(row.synced, true);
    }
    expect(
      await (deviceA.select(deviceA.jobCards)
            ..where((j) => j.id.equals(job.id)))
          .getSingle()
          .then((j) => j.synced),
      true,
    );

    // 3. Owner opens Web: device B pulls everything through the same
    // contract (FK-safe order: customer -> vehicle -> ownership -> job).
    await workerB.syncNow();
    expect(workerB.lastError, isNull);

    final bCustomer = await (deviceB.select(deviceB.customers)
          ..where((c) => c.phone.equals('9876543210')))
        .getSingle();
    expect(bCustomer.id, aCustomer.id);
    expect(bCustomer.name, 'Ramesh Kumar');
    expect(bCustomer.synced, true);

    final bVehicle = await (deviceB.select(deviceB.vehicles)
          ..where((v) => v.numberPlate.equals('KA05MJ4821')))
        .getSingle();
    expect(bVehicle.make, 'Honda');
    expect(bVehicle.currentCustomerId, bCustomer.id);

    final trail = await (deviceB.select(deviceB.carOwnershipHistory)
          ..where((o) => o.vehicleNumberPlate.equals('KA05MJ4821')))
        .get();
    expect(trail, hasLength(1));
    expect(trail.single.customerId, bCustomer.id);

    final bJob = await (deviceB.select(deviceB.jobCards)
          ..where((j) => j.id.equals(job.id)))
        .getSingle();
    expect(bJob.jobNo, aJob.jobNo);
    expect(bJob.complaints, 'Brake noise');
    expect(bJob.status, JobStatus.arrived);
    expect(bJob.synced, true);

    // 4. Owner advances the job on B; the update travels back to A.
    final jobsB = JobRepository(deviceB);
    await jobsB.transitionStatus(job.id, JobStatus.inProgress);
    await jobsB.transitionStatus(job.id, JobStatus.readyForDelivery);
    await workerB.syncNow();
    expect(workerB.lastError, isNull);

    await workerA.syncNow();
    expect(workerA.lastError, isNull);
    final backOnA = await (deviceA.select(deviceA.jobCards)
          ..where((j) => j.id.equals(job.id)))
        .getSingle();
    expect(backOnA.status, JobStatus.readyForDelivery);
    expect(backOnA.synced, true);
  });
}
