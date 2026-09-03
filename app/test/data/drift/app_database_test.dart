import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/drift/enums.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<Customer> insertCustomer({
    String? id,
    String name = 'Ramesh Kumar',
    String phone = '9876543210',
    bool synced = false,
  }) async {
    final row = await db
        .into(db.customers)
        .insertReturning(
          CustomersCompanion.insert(
            id: id ?? 'c1',
            name: name,
            phone: phone,
            synced: Value(synced),
          ),
        );
    return row;
  }

  Future<Vehicle> insertVehicle({
    String plate = 'KA05MJ4821',
    VehicleType type = VehicleType.twoWheeler,
    String customerId = 'c1',
  }) async {
    return db.into(db.vehicles).insertReturning(
          VehiclesCompanion.insert(
            numberPlate: plate,
            vehicleType: type,
            make: 'Honda',
            model: 'Activa 6G',
            fuelType: const Value(FuelType.petrol),
            currentCustomerId: Value(customerId),
          ),
        );
  }

  group('customers', () {
    test('round trip preserves fields', () async {
      final row = await insertCustomer();

      expect(row.name, 'Ramesh Kumar');
      expect(row.phone, '9876543210');
      expect(row.synced, false);
      expect(row.syncedAt, isNull);
      expect(row.createdAt, isNotNull);
    });

    test('phone is unique', () async {
      await insertCustomer();

      await expectLater(
        insertCustomer(id: 'c2'),
        throwsA(anything),
      );
    });
  });

  group('vehicles', () {
    test('round trip preserves fields and enum mapping', () async {
      await insertCustomer();
      final row = await insertVehicle(
        plate: 'ka05 mj-4821'.replaceAll(RegExp(r'[\s-]'), '').toUpperCase(),
        type: VehicleType.fourWheeler,
      );

      expect(row.numberPlate, 'KA05MJ4821');
      expect(row.vehicleType, VehicleType.fourWheeler);
      expect(row.make, 'Honda');
      expect(row.model, 'Activa 6G');
      expect(row.fuelType, FuelType.petrol);
      expect(row.currentCustomerId, 'c1');
      expect(row.synced, false);

      final storedType =
          await db.customSelect('SELECT vehicle_type FROM vehicles').getSingle();
      expect(storedType.data['vehicle_type'], '4W');

      final storedFuel =
          await db.customSelect('SELECT fuel_type FROM vehicles').getSingle();
      expect(storedFuel.data['fuel_type'], 'Petrol');
    });

    test('fuel type and owner are optional', () async {
      await db.into(db.vehicles).insertReturning(
            VehiclesCompanion.insert(
              numberPlate: 'DL3CAB1234',
              vehicleType: VehicleType.twoWheeler,
              make: 'Bajaj',
              model: 'Pulsar',
              currentCustomerId: const Value(null),
              fuelType: const Value(null),
            ),
          );

      final rows = await db.select(db.vehicles).get();
      expect(rows.single.currentCustomerId, isNull);
      expect(rows.single.fuelType, isNull);
    });
  });

  group('car_ownership_history', () {
    test('round trip with open-ended ownership', () async {
      await insertCustomer();
      await insertVehicle();

      final row = await db.into(db.carOwnershipHistory).insertReturning(
            CarOwnershipHistoryCompanion.insert(
              id: 'oh1',
              vehicleNumberPlate: 'KA05MJ4821',
              customerId: const Value('c1'),
              endDate: const Value(null),
            ),
          );

      expect(row.vehicleNumberPlate, 'KA05MJ4821');
      expect(row.customerId, 'c1');
      expect(row.endDate, isNull);
      expect(row.startDate, isNotNull);
    });

    test('closed ownership keeps end date', () async {
      await insertCustomer();
      await insertVehicle();
      final end = DateTime(2026, 1, 15);

      final row = await db.into(db.carOwnershipHistory).insertReturning(
            CarOwnershipHistoryCompanion.insert(
              id: 'oh2',
              vehicleNumberPlate: 'KA05MJ4821',
              endDate: Value(end),
            ),
          );

      expect(row.endDate, end);
    });
  });

  group('job_cards', () {
    test('round trip with defaults', () async {
      await insertCustomer();
      await insertVehicle();

      final row = await db.into(db.jobCards).insertReturning(
            JobCardsCompanion.insert(
              id: 'j1',
              jobNo: 1,
              vehicleNumberPlate: 'KA05MJ4821',
              customerId: 'c1',
              complaints: 'Brake noise, oil change',
              status: JobStatus.arrived,
            ),
          );

      expect(row.status, JobStatus.arrived);
      expect(row.closed, false);
      expect(row.kmReading, isNull);
      expect(row.notes, isNull);
      expect(row.createdBy, isNull);
      expect(row.createdAt, isNotNull);
      expect(row.updatedAt, isNotNull);
      expect(row.synced, false);

      final stored =
          await db.customSelect('SELECT status FROM job_cards').getSingle();
      expect(stored.data['status'], 'Arrived');
    });

    test('status transition round trip through all four states', () async {
      await insertCustomer();
      await insertVehicle();
      var jobNo = await db.into(db.jobCards).insertReturning(
            JobCardsCompanion.insert(
              id: 'j1',
              jobNo: 1,
              vehicleNumberPlate: 'KA05MJ4821',
              customerId: 'c1',
              complaints: 'Service',
              status: JobStatus.arrived,
            ),
          );

      for (final status in [
        JobStatus.inProgress,
        JobStatus.readyForDelivery,
        JobStatus.delivered,
      ]) {
        await (db.update(db.jobCards)
              ..where((t) => t.id.equals('j1')))
            .write(JobCardsCompanion(status: Value(status)));
        final updated = await (db.select(db.jobCards)
              ..where((t) => t.id.equals('j1')))
            .getSingle();
        expect(updated.status, status);
      }
      expect(jobNo.status, JobStatus.arrived);
    });

    test('km reading and notes persist', () async {
      await insertCustomer();
      await insertVehicle();

      final row = await db.into(db.jobCards).insertReturning(
            JobCardsCompanion.insert(
              id: 'j1',
              jobNo: 42,
              vehicleNumberPlate: 'KA05MJ4821',
              customerId: 'c1',
              complaints: 'Clutch hard',
              status: JobStatus.arrived,
              kmReading: const Value(45320),
              notes: const Value('Customer will collect after 5pm'),
            ),
          );

      expect(row.jobNo, 42);
      expect(row.kmReading, 45320);
      expect(row.notes, 'Customer will collect after 5pm');
    });

    test('foreign keys enforced against vehicles and customers', () async {
      await expectLater(
        db.into(db.jobCards).insert(
              JobCardsCompanion.insert(
                id: 'j-orphan',
                jobNo: 99,
                vehicleNumberPlate: 'MISSING01',
                customerId: 'ghost',
                complaints: 'x',
                status: JobStatus.arrived,
              ),
            ),
        throwsA(anything),
      );
    });
  });

  group('old_bills', () {
    test('round trip preserves imported bill record', () async {
      final date = DateTime(2024, 11, 20);

      await db.into(db.vehicles).insertReturning(
            VehiclesCompanion.insert(
              numberPlate: 'HR26DK8339',
              vehicleType: VehicleType.fourWheeler,
              make: 'Hyundai',
              model: 'Creta',
            ),
          );

      final row = await db.into(db.oldBills).insertReturning(
            OldBillsCompanion.insert(
              id: 'b1',
              billNo: 'PB-2024-001',
              billDate: date,
              vehicleCategory: VehicleType.fourWheeler,
              customerName: 'Suresh Verma',
              vehicleNumberPlate: const Value('HR26DK8339'),
              customerPhone: const Value('9812345678'),
              notes: const Value('Full service + clutch plates'),
            ),
          );

      expect(row.billNo, 'PB-2024-001');
      expect(row.billDate, date);
      expect(row.vehicleCategory, VehicleType.fourWheeler);
      expect(row.customerName, 'Suresh Verma');
      expect(row.vehicleNumberPlate, 'HR26DK8339');
      expect(row.customerPhone, '9812345678');
      expect(row.synced, false);
    });

    test('bill_no is unique', () async {
      Future<void> add(String id) => db.into(db.oldBills).insert(
            OldBillsCompanion.insert(
              id: id,
              billNo: 'PB-2024-001',
              billDate: DateTime(2024, 11, 20),
              vehicleCategory: VehicleType.twoWheeler,
              customerName: 'Suresh Verma',
            ),
          );

      await add('b1');
      await expectLater(add('b2'), throwsA(anything));
    });
  });

  group('recommendation_queue', () {
    test('round trip with defaults', () async {
      await insertCustomer();
      await insertVehicle();

      final row = await db.into(db.recommendationQueue).insertReturning(
            RecommendationQueueCompanion.insert(
              id: 'r1',
              customerId: const Value('c1'),
              vehicleNumberPlate: const Value('KA05MJ4821'),
              type: const Value(RecommendationType.serviceDue),
              message: 'Service due — 120 days since last visit',
              scheduledFor: Value(DateTime(2026, 9, 1)),
            ),
          );

      expect(row.type, RecommendationType.serviceDue);
      expect(row.sent, false);
      expect(row.message, contains('120 days'));
      expect(row.syncedAt, isNull);

      final stored = await db
          .customSelect('SELECT type FROM recommendation_queue')
          .getSingle();
      expect(stored.data['type'], 'service_due');
    });

    test('nullable refs can be empty', () async {
      final row = await db.into(db.recommendationQueue).insertReturning(
            RecommendationQueueCompanion.insert(
              id: 'r2',
              message: 'Churn risk follow-up call',
            ),
          );

      expect(row.customerId, isNull);
      expect(row.vehicleNumberPlate, isNull);
      expect(row.scheduledFor, isNull);
      expect(row.type, isNull);
    });
  });

  group('schema mirror', () {
    test('all six tables exist locally', () async {
      final tables = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      ).get();

      final names = tables.map((r) => r.data['name'] as String).toSet();
      for (final expected in [
        'customers',
        'vehicles',
        'car_ownership_history',
        'job_cards',
        'old_bills',
        'recommendation_queue',
      ]) {
        expect(names, contains(expected), reason: 'missing table $expected');
      }
    });

    test('every synced table carries synced/synced_at columns', () async {
      for (final table in [
        'customers',
        'vehicles',
        'car_ownership_history',
        'job_cards',
        'old_bills',
        'recommendation_queue',
      ]) {
        final cols = await db.customSelect(
          'PRAGMA table_info($table)',
        ).get();
        final colNames = cols.map((c) => c.data['name']).toSet();
        expect(colNames, containsAll(['synced', 'synced_at']),
            reason: '$table missing sync columns');
      }
    });
  });
}
