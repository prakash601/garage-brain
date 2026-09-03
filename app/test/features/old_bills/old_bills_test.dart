import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/drift/database_provider.dart';
import 'package:workshop_os/data/drift/enums.dart';
import 'package:workshop_os/data/repositories/old_bills_repository.dart';
import 'package:workshop_os/features/old_bills/old_bills_screen.dart';

void main() {
  late AppDatabase db;
  late OldBillsRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = OldBillsRepository(db);
    await db.into(db.vehicles).insert(
          VehiclesCompanion.insert(
            numberPlate: 'KA05MJ4821',
            vehicleType: VehicleType.twoWheeler,
            make: 'Honda',
            model: 'Activa',
          ),
        );
  });

  tearDown(() async => db.close());

  Widget screen() => ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: OldBillsScreen()),
      );

  Future<void> fillForm(
    WidgetTester tester, {
    required String billNo,
    String plate = 'KA05MJ4821',
    String name = 'Ramesh Kumar',
    String phone = '9876543210',
  }) async {
    await tester.enterText(find.byKey(const Key('bill_no')), billNo);
    await tester.enterText(find.byKey(const Key('bill_plate')), plate);
    await tester.enterText(
        find.byKey(const Key('bill_customer_name')), name);
    await tester.enterText(
        find.byKey(const Key('bill_customer_phone')), phone);
  }

  testWidgets('duplicate bill_no is rejected inline', (tester) async {
    await repo.addBill(
      billNo: 'B-001',
      billDate: DateTime(2025, 1, 1),
      vehicleCategory: VehicleType.twoWheeler,
      customerName: 'Ramesh Kumar',
    );
    await tester.pumpWidget(screen());

    await fillForm(tester, billNo: 'B-001');
    await tester.tap(find.byKey(const Key('save_bill_next')));
    await tester.pump();

    expect(find.text('Bill no B-001 already exists'), findsOneWidget);
    expect(await db.select(db.oldBills).get(), hasLength(1));
  });

  testWidgets('save-and-next keeps plate/customer warm and stores rows',
      (tester) async {
    await tester.pumpWidget(screen());

    await fillForm(tester, billNo: 'B-002');
    await tester.tap(find.byKey(const Key('save_bill_next')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('old_bill_saved_snackbar')), findsOneWidget);

    // Per-bill fields cleared…
    final billNoField =
        tester.widget<TextFormField>(find.byKey(const Key('bill_no')));
    expect(billNoField.controller!.text, isEmpty);
    expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('bill_notes')))
            .controller!
            .text,
        isEmpty);
    // …plate/customer stay warm for the next record.
    expect(tester.widget<TextFormField>(
                find.byKey(const Key('bill_plate')))
            .controller!
            .text,
        'KA05MJ4821');
    expect(tester.widget<TextFormField>(
                find.byKey(const Key('bill_customer_name')))
            .controller!
            .text,
        'Ramesh Kumar');

    // Dismiss the first snackbar before next entry (it overlays the button).
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Enter the next record quickly — plate/customer should still be warm.
    await tester.enterText(find.byKey(const Key('bill_no')), 'B-003');
    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('bill_customer_name')), 'Suresh');
    await tester.pump();
    await tester.tap(find.byKey(const Key('save_bill_next')));
    await tester.pumpAndSettle();

    final bills = await db.select(db.oldBills).get();
    expect(bills.map((b) => b.billNo), containsAll(['B-002', 'B-003']));
  });

  testWidgets('save-and-done resets the full form without popping', (tester) async {
    await tester.pumpWidget(screen());

    await fillForm(tester, billNo: 'B-010');
    await tester.tap(find.byKey(const Key('save_bill_done')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('old_bill_saved_snackbar')), findsOneWidget);
    // Still on the Import screen, blank form ready for an unrelated bill.
    expect(find.text('Import Old Bills'), findsOneWidget);
    expect(
        tester.widget<TextFormField>(find.byKey(const Key('bill_no')))
            .controller!
            .text,
        isEmpty);
    expect(
        tester.widget<TextFormField>(find.byKey(const Key('bill_plate')))
            .controller!
            .text,
        isEmpty);
    // …and the saved bill shows up in Recent imports (scroll down:
    // the list sits at the end of the form's ListView).
    await tester.drag(
        find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('recent_bills_header')), findsOneWidget);
    expect(find.byKey(const Key('recent_bill_B-010')), findsOneWidget);
  });
}
