import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/drift/database_provider.dart';
import 'package:workshop_os/data/drift/enums.dart';
import 'package:workshop_os/data/repositories/customer_repository.dart';
import 'package:workshop_os/data/repositories/job_repository.dart';
import 'package:workshop_os/data/repositories/vehicle_repository.dart';
import 'package:workshop_os/features/dashboard/dashboard_providers.dart';
import 'package:workshop_os/features/dashboard/dashboard_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  // Drift's stream cache schedules a zero-duration Timer when a watch()
  // subscription is cancelled during tree teardown. Awaiting close() inside
  // each test body flushes it before flutter_test's no-pending-timers check.
  Future<void> flushDriftTimers() => db.close();

  Future<String> seedJob({
    String plate = 'KA05MJ4821',
    String phone = '9876543210',
    String complaints = 'Brake noise',
  }) async {
    final customer = await CustomerRepository(db)
        .upsertByNameAndPhone(name: 'Ramesh Kumar', phone: phone);
    await VehicleRepository(db).upsertVehicle(
      numberPlate: plate,
      vehicleType: VehicleType.twoWheeler,
      make: 'Honda',
      model: 'Activa',
      currentCustomerId: customer.id,
    );
    final job = await JobRepository(db).createJob(
      vehicleNumberPlate: plate,
      customerId: customer.id,
      complaints: complaints,
    );
    return job.id;
  }

  Widget screen({bool offline = false}) => ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          // Never touch the real connectivity_plus channel in widget tests:
          // it has no handler here and stalls the stream subscription.
          offlineProvider.overrideWith((ref) => Stream.value(offline)),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      );

  testWidgets('counts pending and completed jobs correctly', (tester) async {
    final arrived = await seedJob(plate: 'KA01AA1111', phone: '9111111111');
    final inProgress = await seedJob(plate: 'KA02BB2222', phone: '9222222222');
    final ready = await seedJob(plate: 'KA03CC3333', phone: '9333333333');
    await seedJob(plate: 'KA04DD4444', phone: '9444444444');

    final repo = JobRepository(db);
    await repo.transitionStatus(inProgress, JobStatus.inProgress);
    await repo.transitionStatus(ready, JobStatus.inProgress);
    await repo.transitionStatus(ready, JobStatus.readyForDelivery);
    await repo.transitionStatus(arrived, JobStatus.inProgress);
    await repo.transitionStatus(arrived, JobStatus.readyForDelivery);
    await repo.transitionStatus(arrived, JobStatus.delivered);

    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('offline_badge')), findsNothing);
    expect(find.byKey(const Key('pending_count')), findsOneWidget);
    expect(find.byKey(const Key('completed_count')), findsOneWidget);
    // Pending: Arrived + InProgress + ReadyForDelivery = 3; Delivered = 1.
    expect(find.descendant(
      of: find.byKey(const Key('pending_count')),
      matching: find.text('3'),
    ), findsOneWidget);
    expect(find.descendant(
      of: find.byKey(const Key('completed_count')),
      matching: find.text('1'),
    ), findsOneWidget);

    await flushDriftTimers();
  });

  testWidgets('manual close removes a Delivered job from the active list',
      (tester) async {
    final jobId = await seedJob(plate: 'KA05MJ4821');
    final repo = JobRepository(db);
    for (final next in [
      JobStatus.inProgress,
      JobStatus.readyForDelivery,
      JobStatus.delivered
    ]) {
      final current = await repo.byId(jobId);
      await repo.transitionStatus(current.id, next);
    }

    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('job_tile_1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('close_job_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_close_job')));
    await tester.pumpAndSettle();

    final job = await repo.byId(jobId);
    expect(job.closed, isTrue);
    expect(find.byKey(const Key('job_tile_1')), findsNothing);

    await flushDriftTimers();
  });

  testWidgets('status filter narrows the visible list', (tester) async {
    final arrived = await seedJob(plate: 'KA01AA1111', phone: '9111111111');
    await seedJob(plate: 'KA02BB2222', phone: '9222222222');

    final repo = JobRepository(db);
    await repo.transitionStatus(arrived, JobStatus.inProgress);
    await repo.transitionStatus(arrived, JobStatus.readyForDelivery);
    await repo.transitionStatus(arrived, JobStatus.delivered);

    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('job_tile_1')), findsOneWidget);
    expect(find.byKey(const Key('job_tile_2')), findsOneWidget);

    await tester.tap(find.byKey(const Key('filter_delivered')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('job_tile_1')), findsOneWidget);
    expect(find.byKey(const Key('job_tile_2')), findsNothing);

    await flushDriftTimers();
  });

  testWidgets('offline badge shows when connectivity is lost',
      (tester) async {
    await seedJob();
    await tester.pumpWidget(screen(offline: true));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('offline_badge')), findsOneWidget);

    await flushDriftTimers();
  });
}
