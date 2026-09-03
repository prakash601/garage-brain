import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/drift/enums.dart';
import 'package:workshop_os/data/repositories/job_repository.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  late JobRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = JobRepository(db);
    await seedCustomer(db);
    await seedVehicle(db);
  });

  tearDown(() async => db.close());

  Future<JobCard> seedJob({int jobNo = 1}) =>
      db.into(db.jobCards).insertReturning(
            JobCardsCompanion.insert(
              id: 'j$jobNo',
              jobNo: jobNo,
              vehicleNumberPlate: 'KA05MJ4821',
              customerId: 'c1',
              complaints: 'Brake noise',
              status: JobStatus.arrived,
            ),
          );

  group('createJob', () {
    test('uses client UUID and local placeholder job_no (max + 1)',
        () async {
      final first = await repo.createJob(
        vehicleNumberPlate: 'KA05MJ4821',
        customerId: 'c1',
        complaints: 'Service',
      );
      expect(first.id.length, 36);
      expect(first.jobNo, 1);
      expect(first.status, JobStatus.arrived);
      expect(first.closed, false);
      expect(first.synced, false);

      final second = await repo.createJob(
        vehicleNumberPlate: 'KA05MJ4821',
        customerId: 'c1',
        complaints: 'Clutch',
      );
      expect(second.jobNo, first.jobNo + 1);
    });

    test('rejects unknown vehicle/customer via FK', () async {
      await expectLater(
        repo.createJob(
          vehicleNumberPlate: 'GHOST0001',
          customerId: 'c1',
          complaints: 'x',
        ),
        throwsA(anything),
      );
    });
  });

  group('status transitions', () {
    test('legal linear flow succeeds and flags row unsynced', () async {
      await seedJob();
      var job = await repo.transitionStatus('j1', JobStatus.inProgress);
      expect(job.status, JobStatus.inProgress);

      job = await repo.transitionStatus('j1', JobStatus.readyForDelivery);
      job = await repo.transitionStatus('j1', JobStatus.delivered);
      expect(job.status, JobStatus.delivered);
      expect(job.synced, false);
      expect(job.updatedAt.isAfter(DateTime(2020)), true);
    });

    test('skipping a step is rejected', () async {
      await seedJob();
      expect(
        () => repo.transitionStatus('j1', JobStatus.readyForDelivery),
        throwsA(isA<IllegalStatusTransitionException>()),
      );
    });

    test('backwards move is rejected', () async {
      await seedJob();
      await repo.transitionStatus('j1', JobStatus.inProgress);
      await expectLater(
        repo.transitionStatus('j1', JobStatus.arrived),
        throwsA(isA<IllegalStatusTransitionException>()),
      );
    });

    test('no transition out of Delivered', () async {
      await seedJob();
      for (final s in [
        JobStatus.inProgress,
        JobStatus.readyForDelivery,
        JobStatus.delivered
      ]) {
        await repo.transitionStatus('j1', s);
      }
      await expectLater(
        repo.transitionStatus('j1', JobStatus.arrived),
        throwsA(isA<IllegalStatusTransitionException>()),
      );
    });
  });

  group('manual close', () {
    test('close allowed only on Delivered rows', () async {
      await seedJob();
      await expectLater(
        repo.closeJob('j1'),
        throwsA(isA<JobNotCloseableException>()),
      );

      await repo.transitionStatus('j1', JobStatus.inProgress);
      await repo.transitionStatus('j1', JobStatus.readyForDelivery);
      await repo.transitionStatus('j1', JobStatus.delivered);

      final closed = await repo.closeJob('j1');
      expect(closed.closed, true);
      expect(closed.synced, false);
    });

    test('double close is rejected', () async {
      await seedJob();
      for (final s in [
        JobStatus.inProgress,
        JobStatus.readyForDelivery,
        JobStatus.delivered
      ]) {
        await repo.transitionStatus('j1', s);
      }
      await repo.closeJob('j1');
      await expectLater(
        repo.closeJob('j1'),
        throwsA(isA<JobNotCloseableException>()),
      );
    });
  });

  group('updateNotes', () {
    test('persists notes and flags unsynced', () async {
      await seedJob();
      await (db.update(db.jobCards)..where((j) => j.id.equals('j1')))
          .write(const JobCardsCompanion(synced: Value(true)));

      final updated = await repo.updateNotes('j1', 'Collect after 5pm');
      expect(updated.notes, 'Collect after 5pm');
      expect(updated.synced, false);
    });
  });
}
