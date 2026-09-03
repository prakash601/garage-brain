import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/drift/database_provider.dart';
import 'package:workshop_os/data/drift/enums.dart';
import 'package:workshop_os/features/create_job/create_job_screen.dart';
import 'package:workshop_os/features/create_job/create_job_service.dart';
import 'package:workshop_os/features/create_job/makes_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Widget screen() => ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          makesProvider.overrideWith((ref) => Future.value(['Honda', 'Hero'])),
        ],
        child: const MaterialApp(home: CreateJobScreen()),
      );

  group('CreateJobService', () {
    test('offline save lands customer/vehicle/job in the sync queue',
        () async {
      final service = CreateJobService(db);

      final job = await service.createJob(
        plate: 'KA05MJ4821',
        vehicleType: VehicleType.twoWheeler,
        make: 'Honda',
        model: 'Activa 6G',
        fuelType: FuelType.petrol,
        name: 'Ramesh Kumar',
        phone: '9876543210',
        complaints: 'Brake noise',
      );

      // Everything is local-first: rows exist but are unsynced.
      expect(job.synced, isFalse);
      expect(job.status, JobStatus.arrived);

      final vehicle = await (db.select(db.vehicles)
            ..where((v) => v.numberPlate.equals('KA05MJ4821')))
          .getSingle();
      expect(vehicle.synced, isFalse);
      expect(vehicle.currentCustomerId, job.customerId);

      final customer = await db.select(db.customers).getSingle();
      expect(customer.phone, '9876543210');
      expect(customer.synced, isFalse);
    });

    test('existing phone pre-fills the same customer identity', () async {
      final service = CreateJobService(db);
      await service.createJob(
        plate: 'KA05MJ4821',
        vehicleType: VehicleType.twoWheeler,
        make: 'Honda',
        model: 'Activa',
        name: 'Ramesh Kumar',
        phone: '9876543210',
        complaints: 'Service',
      );

      // Same phone returns the same customer row even with a new spelling.
      await service.createJob(
        plate: 'KA01AB1111',
        vehicleType: VehicleType.fourWheeler,
        make: 'Tata',
        model: 'Nexon',
        name: 'Ramesh K',
        phone: '+91 98765 43210',
        complaints: 'AC not cooling',
      );

      final customers = await db.select(db.customers).get();
      expect(customers, hasLength(1));
      expect(customers.single.name, 'Ramesh K');

      // Each vehicle gets its own open ownership row for this customer.
      final ownership = await db.select(db.carOwnershipHistory).get();
      expect(ownership, hasLength(2));
      expect(ownership.every((o) => o.endDate == null), isTrue);
      final vehicles = await db.select(db.vehicles).get();
      expect(
        vehicles.every((v) => v.currentCustomerId == customers.single.id),
        isTrue,
      );
    });

    test('validation rejects bad plate/phone/complaints', () async {
      final service = CreateJobService(db);
      expect(
        () => service.createJob(
          plate: 'KA@05!',
          vehicleType: VehicleType.twoWheeler,
          make: 'Honda',
          model: 'Activa',
          name: 'Ramesh',
          phone: '12345',
          complaints: '',
        ),
        throwsA(isA<CreateJobValidationException>()),
      );
      expect(await db.select(db.jobCards).get(), isEmpty);
    });
  });

  group('CreateJobScreen widget', () {
    Future<void> enterField(WidgetTester tester, Key key, String text) async {
      await tester.scrollUntilVisible(find.byKey(key), 200,
          scrollable: find.byType(Scrollable).first);
      await tester.enterText(find.byKey(key), text);
      await tester.pump();
    }

    Future<void> fillHappyPath(WidgetTester tester) async {
      await enterField(tester, const Key('job_plate'), 'ka05 mj-4821');
      await tester.tap(find.byKey(const Key('job_make')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Honda').last);
      await tester.pumpAndSettle();
      await enterField(tester, const Key('job_model'), 'Activa 6G');
      await enterField(tester, const Key('customer_phone'), '9876543210');
      await enterField(tester, const Key('customer_name'), 'Ramesh Kumar');
      await enterField(
          tester, const Key('job_complaints'), 'Brake noise');
      await enterField(tester, const Key('job_km'), '12456');
      await tester.scrollUntilVisible(find.byKey(const Key('save_job')), 200,
          scrollable: find.byType(Scrollable).first);
    }

    testWidgets('full happy path saves instantly with success snackbar',
        (tester) async {
      await tester.pumpWidget(screen());

      await fillHappyPath(tester);
      await tester.tap(find.byKey(const Key('save_job')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('old_bill_saved_snackbar')), findsNothing);
      expect(find.text('Job created'), findsOneWidget);
      expect(find.textContaining('KA05MJ4821'), findsNothing);

      final jobs = await db.select(db.jobCards).get();
      expect(jobs, hasLength(1));
      expect(jobs.single.vehicleNumberPlate, 'KA05MJ4821');
      expect(jobs.single.kmReading, 12456);
    });

    testWidgets('live plate flag turns green on classic plates',
        (tester) async {
      await tester.pumpWidget(screen());

      await tester.enterText(
          find.byKey(const Key('job_plate')), 'KA05MJ4821');
      await tester.pump();

      expect(find.byKey(const Key('job_plate_flag_green')), findsOneWidget);
    });

    testWidgets('invalid phone blocks save via validation', (tester) async {      await tester.pumpWidget(screen());

      await enterField(tester, const Key('job_plate'), 'KA05MJ4821');
      await enterField(tester, const Key('customer_phone'), '12345');
      await enterField(tester, const Key('customer_name'), 'Ramesh Kumar');
      await tester.scrollUntilVisible(find.byKey(const Key('save_job')), 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(find.byKey(const Key('save_job')));
      await tester.pump();

      expect(find.text('Enter a valid mobile number'), findsOneWidget);
      expect(await db.select(db.jobCards).get(), isEmpty);
    });

    testWidgets('warns when the plate already has an open job',
        (tester) async {
      final service = CreateJobService(db);
      await service.createJob(
        plate: 'KA05MJ4821',
        vehicleType: VehicleType.twoWheeler,
        make: 'Honda',
        model: 'Activa',
        name: 'Ramesh Kumar',
        phone: '9876543210',
        complaints: 'Brake noise',
      );

      await tester.pumpWidget(screen());
      await enterField(tester, const Key('job_plate'), 'KA05MJ4821');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('open_job_warning')), findsOneWidget);
      expect(find.byKey(const Key('view_open_job')), findsOneWidget);
    });
  });
}
