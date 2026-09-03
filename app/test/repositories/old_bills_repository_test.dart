import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/drift/enums.dart';
import 'package:workshop_os/data/repositories/old_bills_repository.dart';

void main() {
  late AppDatabase db;
  late OldBillsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = OldBillsRepository(db);
  });

  tearDown(() async => db.close());

  test('adds bill with client UUID and stays unsynced', () async {
    await db.into(db.vehicles).insert(
          VehiclesCompanion.insert(
            numberPlate: 'HR26DK8339',
            vehicleType: VehicleType.fourWheeler,
            make: 'Hyundai',
            model: 'Creta',
          ),
        );
    final bill = await repo.addBill(
      billNo: 'PB-2024-001',
      billDate: DateTime(2024, 11, 20),
      vehicleCategory: VehicleType.fourWheeler,
      customerName: 'Suresh Verma',
      vehicleNumberPlate: 'HR26DK8339',
      customerPhone: '9812345678',
      notes: 'Full service',
    );

    expect(bill.id.length, 36);
    expect(bill.billNo, 'PB-2024-001');
    expect(bill.synced, false);
  });

  test('duplicate bill_no rejected inline', () async {
    await repo.addBill(
      billNo: 'PB-2024-001',
      billDate: DateTime(2024, 11, 20),
      vehicleCategory: VehicleType.twoWheeler,
      customerName: 'Suresh Verma',
    );

    await expectLater(
      repo.addBill(
        billNo: 'PB-2024-001',
        billDate: DateTime(2025, 1, 5),
        vehicleCategory: VehicleType.twoWheeler,
        customerName: 'Another Name',
      ),
      throwsA(isA<DuplicateBillNoException>()),
    );

    final rows = await db.select(db.oldBills).get();
    expect(rows, hasLength(1));
  });
}
