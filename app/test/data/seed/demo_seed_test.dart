import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/seed/demo_seed.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('DemoSeed seeds expected rows', () async {
    await DemoSeed.seed(db);
    final customers = await db.select(db.customers).get();
    final vehicles = await db.select(db.vehicles).get();
    final jobs = await db.select(db.jobCards).get();
    final bills = await db.select(db.oldBills).get();
    final history = await db.select(db.carOwnershipHistory).get();

    expect(customers.length, 6);
    expect(vehicles.length, 6);
    expect(jobs.length, 6);
    expect(bills.length, 2);
    expect(history.length, 6);
  });

  test('DemoSeed is idempotent — second run does not duplicate', () async {
    await DemoSeed.seed(db);
    await DemoSeed.seed(db);
    final customers = await db.select(db.customers).get();
    final vehicles = await db.select(db.vehicles).get();
    final jobs = await db.select(db.jobCards).get();
    final bills = await db.select(db.oldBills).get();

    expect(customers.length, 6);
    expect(vehicles.length, 6);
    expect(jobs.length, 6);
    expect(bills.length, 2);
  });

  test('DemoSeed covers 2W and 4W and BH-series plate', () async {
    await DemoSeed.seed(db);
    final vehicles = await db.select(db.vehicles).get();
    final plates = vehicles.map((v) => v.numberPlate).toSet();
    expect(plates.contains('21BH2345A'), true);
    expect(vehicles.where((v) => v.vehicleType.name == 'twoWheeler').length,
        greaterThan(0));
    expect(vehicles.where((v) => v.vehicleType.name == 'fourWheeler').length,
        greaterThan(0));
  });
}
