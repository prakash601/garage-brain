import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/drift/database_provider.dart';
import 'package:workshop_os/data/drift/enums.dart';
import 'package:workshop_os/features/search/search_screen.dart';
import 'package:workshop_os/features/search/search_service.dart';
import 'package:workshop_os/data/repositories/customer_repository.dart';
import 'package:workshop_os/data/repositories/job_repository.dart';
import 'package:workshop_os/data/repositories/old_bills_repository.dart';
import 'package:workshop_os/data/repositories/vehicle_repository.dart';

void main() {
  late AppDatabase db;
  late SearchService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    service = SearchService(db);
  });

  tearDown(() async => db.close());

  Future<String> seedJob({
    String plate = 'KA05MJ4821',
    String phone = '9876543210',
    String name = 'Ramesh Kumar',
    String complaints = 'Brake noise',
  }) async {
    final customer = await CustomerRepository(db)
        .upsertByNameAndPhone(name: name, phone: phone);
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

  group('SearchService (Drift only)', () {
    test('matches plate fragments', () async {
      final jobId = await seedJob();

      final hits = await service.search('4821');
      expect(hits, hasLength(1));
      expect(hits.single.jobId, jobId);
      expect(hits.single.headline, contains('KA05MJ4821'));
    });

    test('matches phone digits', () async {
      final jobId = await seedJob();

      final hits = await service.search('9876543210');
      expect(hits, hasLength(1));
      expect(hits.single.jobId, jobId);
    });

    test('merges old_bills into the same timeline', () async {
      await seedJob();
      await OldBillsRepository(db).addBill(
        billNo: 'B-101',
        billDate: DateTime(2025, 1, 10),
        vehicleCategory: VehicleType.twoWheeler,
        customerName: 'Ramesh Kumar',
        vehicleNumberPlate: 'KA05MJ4821',
      );

      final hits = await service.search('KA05MJ4821');
      expect(hits, hasLength(2));
      // Recent-first timeline: today's job first, imported bill last.
      expect(hits.first.isJob, isTrue);
      expect(hits.last.isOldBill, isTrue);
      expect(hits.last.headline, contains('B-101'));
    });

    test('empty and junk queries return nothing', () async {
      await seedJob();
      expect(await service.search(''), isEmpty);
      expect(await service.search('!!'), isEmpty);
    });

    test('matches customer names', () async {
      final jobId = await seedJob(name: 'Ramesh Kumar');

      final hits = await service.search('Ramesh');
      expect(hits, hasLength(1));
      expect(hits.single.jobId, jobId);
    });

    test('LIKE wildcards in input do not widen the match', () async {
      await seedJob();
      expect(SearchService.likeSafe('100%_\\'), '100');
      final hits = await service.search('KA05MJ4821%_\\');
      expect(hits, hasLength(1));
    });
  });

  group('SearchScreen widget', () {
    Widget screen(String jobId) => ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/search',
              routes: [
                GoRoute(
                  path: '/search',
                  builder: (_, _) => const SearchScreen(),
                ),
                GoRoute(
                  path: '/job/:id',
                  builder: (_, state) =>
                      Text('detail:${state.pathParameters['id']}'),
                ),
              ],
            ),
          ),
        );

    testWidgets('plate hit navigates to job detail on tap', (tester) async {
      final jobId = await seedJob();
      await tester.pumpWidget(screen(jobId));

      await tester.enterText(find.byKey(const Key('search_field')), 'MJ48');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.textContaining('KA05MJ4821'), findsOneWidget);

      await tester.tap(find.byKey(const Key('hit_0')));
      await tester.pumpAndSettle();
      expect(find.text('detail:$jobId'), findsOneWidget);
    });

    testWidgets('phone hit shows the matching job', (tester) async {
      await seedJob(phone: '9123456780');
      await tester.pumpWidget(screen('unused'));

      await tester.enterText(
          find.byKey(const Key('search_field')), '9123456780');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('hit_0')), findsOneWidget);
    });

    testWidgets('amber flag appears for non-classic plates', (tester) async {
      await tester.pumpWidget(screen('none'));

      await tester.enterText(
          find.byKey(const Key('search_field')), '21BH2345A');
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('plate_flag_amber')), findsOneWidget);
    });

    testWidgets('green flag for classic plates, red for junk',
        (tester) async {
      await tester.pumpWidget(screen('none'));

      await tester.enterText(
          find.byKey(const Key('search_field')), 'KA05MJ4821');
      await tester.pump();
      expect(find.byKey(const Key('plate_flag_green')), findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('search_field')), 'KA@05!');
      await tester.pump();
      expect(find.byKey(const Key('plate_flag_red')), findsOneWidget);
    });

    testWidgets('not-found state offers Create Job CTA', (tester) async {
      await tester.pumpWidget(screen('none'));

      await tester.enterText(
          find.byKey(const Key('search_field')), 'ZZZ999ZZ');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('search_create_job_cta')), findsOneWidget);
      expect(find.text('Create Job'), findsOneWidget);
    });
  });
}
