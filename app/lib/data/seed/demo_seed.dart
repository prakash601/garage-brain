import 'package:drift/drift.dart';

import '../drift/app_database.dart';
import '../drift/enums.dart';

class DemoSeed {
  static const _customerIds = [
    '00000000-0000-4000-a000-000000000001',
    '00000000-0000-4000-a000-000000000002',
    '00000000-0000-4000-a000-000000000003',
    '00000000-0000-4000-a000-000000000004',
    '00000000-0000-4000-a000-000000000005',
    '00000000-0000-4000-a000-000000000006',
  ];

  static const _vehiclePlates = [
    'KA05MJ4821',
    'MH12AB1234',
    'DL10CA0007',
    '21BH2345A',
    'TN07BY1111',
    'UP16CT2025',
  ];

  static const _jobIds = [
    '10000000-0000-4000-a000-000000000001',
    '10000000-0000-4000-a000-000000000002',
    '10000000-0000-4000-a000-000000000003',
    '10000000-0000-4000-a000-000000000004',
    '10000000-0000-4000-a000-000000000005',
    '10000000-0000-4000-a000-000000000006',
  ];

  static Future<void> seed(AppDatabase db) async {
    await _seedCustomers(db);
    await _seedVehicles(db);
    await _seedOwnership(db);
    await _seedJobs(db);
    await _seedOldBills(db);
  }

  static Future<void> _seedCustomers(AppDatabase db) async {
    final rows = [
      ('Ramesh Kumar', '9876543210', _customerIds[0]),
      ('Priya Sharma', '9000000001', _customerIds[1]),
      ('Amit Patel', '9123456789', _customerIds[2]),
      ('Sunita Rao', '9988776655', _customerIds[3]),
      ('Vikram Singh', '9812345678', _customerIds[4]),
      ('Anjali Desai', '9090909090', _customerIds[5]),
    ];
    for (final (name, phone, id) in rows) {
      await db.into(db.customers).insertOnConflictUpdate(
            CustomersCompanion.insert(
              id: id,
              name: name,
              phone: phone,
            ),
          );
    }
  }

  static Future<void> _seedVehicles(AppDatabase db) async {
    final rows = [
      (_vehiclePlates[0], VehicleType.twoWheeler, 'Honda', 'Activa 6G', FuelType.petrol, _customerIds[0]),
      (_vehiclePlates[1], VehicleType.fourWheeler, 'Maruti Suzuki', 'Swift', FuelType.petrol, _customerIds[1]),
      (_vehiclePlates[2], VehicleType.twoWheeler, 'Royal Enfield', 'Classic 350', FuelType.petrol, _customerIds[2]),
      (_vehiclePlates[3], VehicleType.fourWheeler, 'Hyundai', 'Creta', FuelType.diesel, _customerIds[3]),
      (_vehiclePlates[4], VehicleType.twoWheeler, 'TVS', 'Apache RTR 160', FuelType.petrol, _customerIds[4]),
      (_vehiclePlates[5], VehicleType.fourWheeler, 'Tata', 'Nexon EV', FuelType.electric, _customerIds[5]),
    ];
    for (final (plate, type, make, model, fuel, cid) in rows) {
      await db.into(db.vehicles).insertOnConflictUpdate(
            VehiclesCompanion.insert(
              numberPlate: plate,
              vehicleType: type,
              make: make,
              model: model,
              fuelType: Value(fuel),
              currentCustomerId: Value(cid),
            ),
          );
    }
  }

  static Future<void> _seedOwnership(AppDatabase db) async {
    for (var i = 0; i < _vehiclePlates.length; i++) {
      final id = '20000000-0000-4000-a000-00000000000${i + 1}';
      await db.into(db.carOwnershipHistory).insertOnConflictUpdate(
            CarOwnershipHistoryCompanion.insert(
              id: id,
              vehicleNumberPlate: _vehiclePlates[i],
              customerId: Value(_customerIds[i]),
              startDate: Value(DateTime(2025, 1, 1 + i)),
            ),
          );
    }
  }

  static Future<void> _seedJobs(AppDatabase db) async {
    final now = DateTime.now();
    final statuses = [
      JobStatus.arrived,
      JobStatus.inProgress,
      JobStatus.readyForDelivery,
      JobStatus.delivered,
      JobStatus.arrived,
      JobStatus.inProgress,
    ];
    for (var i = 0; i < _jobIds.length; i++) {
      final closed = statuses[i] == JobStatus.delivered ? false : false;
      await db.into(db.jobCards).insertOnConflictUpdate(
            JobCardsCompanion.insert(
              id: _jobIds[i],
              jobNo: 1000 + i + 1,
              vehicleNumberPlate: _vehiclePlates[i],
              customerId: _customerIds[i],
              complaints: _complaints[i],
              status: statuses[i],
              kmReading: Value(10000 + i * 2500),
              notes: Value(i == 3 ? 'Customer to be notified' : null),
              createdAt: Value(now.subtract(Duration(days: i))),
              updatedAt: Value(now.subtract(Duration(days: i))),
              closed: Value(closed),
            ),
          );
    }
  }

  static Future<void> _seedOldBills(AppDatabase db) async {
    final bills = [
      ('30000000-0000-4000-a000-000000000001', 'BILL-OLD-001', DateTime(2024, 6, 15), _vehiclePlates[0], VehicleType.twoWheeler, 'Ramesh Kumar', '9876543210'),
      ('30000000-0000-4000-a000-000000000002', 'BILL-OLD-002', DateTime(2024, 7, 20), _vehiclePlates[1], VehicleType.fourWheeler, 'Priya Sharma', '9000000001'),
    ];
    for (final (id, billNo, date, plate, cat, cname, cphone) in bills) {
      await db.into(db.oldBills).insertOnConflictUpdate(
            OldBillsCompanion.insert(
              id: id,
              billNo: billNo,
              billDate: date,
              vehicleCategory: cat,
              customerName: cname,
              vehicleNumberPlate: Value(plate),
              customerPhone: Value(cphone),
              notes: const Value('Imported from paper book — demo seed'),
            ),
          );
    }
  }

  static const _complaints = [
    'Brake noise at low speed',
    'AC not cooling, gas check needed',
    'Engine oil leak near head gasket',
    'BH series registration — first service',
    'Chain slack and gear shifting hard',
    'Battery draining overnight',
  ];
}
