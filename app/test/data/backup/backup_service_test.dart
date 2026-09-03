import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/data/backup/backup_service.dart';
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/drift/enums.dart';

void main() {
  late AppDatabase db;
  late BackupService service;
  late Directory tmpDir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    service = BackupService(db);
    tmpDir = await Directory.systemTemp.createTemp('backup_test_');
  });

  tearDown(() async {
    await db.close();
    if (await tmpDir.exists()) await tmpDir.delete(recursive: true);
  });

  Future<void> seedMinimal() async {
    await db.into(db.customers).insert(CustomersCompanion.insert(
          id: 'c1',
          name: 'Ramesh Kumar',
          phone: '9876543210',
        ));
    await db.into(db.vehicles).insert(VehiclesCompanion.insert(
          numberPlate: 'KA05MJ4821',
          vehicleType: VehicleType.twoWheeler,
          make: 'Honda',
          model: 'Activa 6G',
        ));
    await db.into(db.jobCards).insert(JobCardsCompanion.insert(
          id: 'j1',
          jobNo: 1,
          vehicleNumberPlate: 'KA05MJ4821',
          customerId: 'c1',
          complaints: 'Brake noise',
          status: JobStatus.arrived,
        ));
    await db.into(db.oldBills).insert(OldBillsCompanion.insert(
          id: 'b1',
          billNo: 'BILL-001',
          billDate: DateTime(2024, 6, 1),
          vehicleCategory: VehicleType.twoWheeler,
          customerName: 'Ramesh Kumar',
        ));
  }

  test('buildExportJson contains all tables', () async {
    await seedMinimal();
    final json = await service.buildExportJson();
    expect(json['version'], 1);
    expect(json['exported_at'], isA<String>());
    final tables = json['tables'] as Map<String, dynamic>;
    for (final key in [
      'customers',
      'vehicles',
      'car_ownership_history',
      'job_cards',
      'old_bills',
      'recommendation_queue',
    ]) {
      expect(tables.containsKey(key), true, reason: 'missing $key');
    }
    expect((tables['customers'] as List).length, 1);
    expect((tables['vehicles'] as List).length, 1);
    expect((tables['job_cards'] as List).length, 1);
    expect((tables['old_bills'] as List).length, 1);
  });

  test('writeExportFile creates file with all tables', () async {
    await seedMinimal();
    final file = await service.writeExportFile(directoryPath: tmpDir.path);
    expect(await file.exists(), true);
    final decoded = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final tables = decoded['tables'] as Map<String, dynamic>;
    expect(tables['customers'], isNotEmpty);
    expect(tables['job_cards'], isNotEmpty);
  });

  test('restoreFromJson round-trips into fresh db and is idempotent', () async {
    await seedMinimal();
    final exported = await service.buildExportJson();

    final db2 = AppDatabase(NativeDatabase.memory());
    final service2 = BackupService(db2);
    await service2.restoreFromJson(exported);
    await service2.restoreFromJson(exported);

    final customers = await db2.select(db2.customers).get();
    final vehicles = await db2.select(db2.vehicles).get();
    final jobs = await db2.select(db2.jobCards).get();
    final bills = await db2.select(db2.oldBills).get();

    expect(customers.length, 1);
    expect(vehicles.length, 1);
    expect(jobs.length, 1);
    expect(bills.length, 1);

    await db2.close();
  });

  test('export then restore preserves counts for empty db', () async {
    final exported = await service.buildExportJson();
    final tables = exported['tables'] as Map<String, dynamic>;
    for (final v in tables.values) {
      expect((v as List).isEmpty, true);
    }
    final db2 = AppDatabase(NativeDatabase.memory());
    await BackupService(db2).restoreFromJson(exported);
    expect((await db2.select(db2.customers).get()).isEmpty, true);
    await db2.close();
  });
}
