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
import 'package:workshop_os/features/job_detail/job_detail_screen.dart';
import 'package:workshop_os/features/job_detail/whatsapp.dart';

void main() {
  group('buildWhatsAppReadyUrl (deep link construction)', () {
    test('builds wa.me link with country code and prefilled message', () {
      final url = buildWhatsAppReadyUrl(
        phone: '9876543210',
        jobNo: 'JOB-000001',
        vehicleLabel: 'Honda Activa (KA05MJ4821)',
      );

      expect(url, startsWith('https://wa.me/919876543210?text='));
      final decoded = Uri.decodeComponent(
          Uri.parse(url).queryParameters['text']!);
      expect(decoded, contains('Honda Activa (KA05MJ4821)'));
      expect(decoded, contains('JOB-000001'));
      expect(decoded, contains('ready for delivery'));
    });

    test('does not double-prefix an already-prefixed number', () {
      final url = buildWhatsAppReadyUrl(
        phone: '+91 9876543210',
        jobNo: 'JOB-000002',
        vehicleLabel: 'Tata Nexon',
      );
      expect(url, startsWith('https://wa.me/919876543210?text='));
    });
  });

  group('JobDetailScreen status stepper', () {
    late AppDatabase db;
    late JobRepository repo;
    late String jobId;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = JobRepository(db);
    });

    tearDown(() async => db.close());

    Future<void> seed() async {
      final customer = await CustomerRepository(db)
          .upsertByNameAndPhone(name: 'Ramesh Kumar', phone: '9876543210');
      await VehicleRepository(db).upsertVehicle(
        numberPlate: 'KA05MJ4821',
        vehicleType: VehicleType.twoWheeler,
        make: 'Honda',
        model: 'Activa',
        currentCustomerId: customer.id,
      );
      jobId = (await repo.createJob(
        vehicleNumberPlate: 'KA05MJ4821',
        customerId: customer.id,
        complaints: 'Brake noise',
      ))
          .id;
    }

    Widget screen() => ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(home: JobDetailScreen(jobId: jobId)),
        );

    testWidgets('walks the linear flow Arrived → Delivered step by step',
        (tester) async {
      await seed();
      await tester.pumpWidget(screen());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('advance_arrived')), findsOneWidget);
      expect(find.byKey(const Key('whatsapp_ready_button')), findsNothing);

      await tester.tap(find.byKey(const Key('advance_arrived')));
      await tester.pumpAndSettle();

      expect((await repo.byId(jobId)).status, JobStatus.inProgress);
      expect(find.byKey(const Key('stepper_inProgress')), findsOneWidget);

      await tester.tap(find.byKey(const Key('advance_inProgress')));
      await tester.pumpAndSettle();

      expect((await repo.byId(jobId)).status, JobStatus.readyForDelivery);
      // WhatsApp button appears exactly at ReadyForDelivery.
      expect(find.byKey(const Key('whatsapp_ready_button')), findsOneWidget);
      expect(find.byKey(const Key('advance_readyForDelivery')),
          findsOneWidget);

      await tester.tap(find.byKey(const Key('advance_readyForDelivery')));
      await tester.pumpAndSettle();

      expect((await repo.byId(jobId)).status, JobStatus.delivered);
      expect(find.byKey(const Key('stepper_delivered')), findsOneWidget);
      // Terminal state: no further transition possible from the UI.
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('notes can be edited and saved', (tester) async {
      await seed();
      await tester.pumpWidget(screen());
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('job_notes')), 'Customer will pick up at 6pm');
      await tester.tap(find.byKey(const Key('save_notes')));
      await tester.pumpAndSettle();

      expect((await repo.byId(jobId)).notes, 'Customer will pick up at 6pm');
    });
  });
}
