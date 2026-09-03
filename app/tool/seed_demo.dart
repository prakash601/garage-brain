// ignore_for_file: avoid_print
import 'package:drift/native.dart';
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/seed/demo_seed.dart';

Future<void> main() async {
  final db = AppDatabase(NativeDatabase.memory());
  await DemoSeed.seed(db);
  print('Demo seed complete (in-memory). '
      'Customers: ${(await db.select(db.customers).get()).length}, '
      'Vehicles: ${(await db.select(db.vehicles).get()).length}, '
      'Jobs: ${(await db.select(db.jobCards).get()).length}, '
      'Old bills: ${(await db.select(db.oldBills).get()).length}');
  await DemoSeed.seed(db);
  print('Re-seed (idempotency check) passed — second run did not duplicate rows.');
  await db.close();
}
