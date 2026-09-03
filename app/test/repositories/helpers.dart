import 'package:drift/drift.dart' hide isNull;
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/drift/enums.dart';

Future<Customer> seedCustomer(
  AppDatabase db, {
  String id = 'c1',
  String name = 'Ramesh Kumar',
  String phone = '9876543210',
}) {
  return db.into(db.customers).insertReturning(
        CustomersCompanion.insert(id: id, name: name, phone: phone),
      );
}

Future<Vehicle> seedVehicle(
  AppDatabase db, {
  String plate = 'KA05MJ4821',
  VehicleType type = VehicleType.twoWheeler,
  String make = 'Honda',
  String model = 'Activa 6G',
  String? customerId = 'c1',
}) async {
  return db.into(db.vehicles).insertReturning(
            VehiclesCompanion.insert(
              numberPlate: plate,
              vehicleType: type,
              make: make,
              model: model,
              currentCustomerId: Value(customerId),
            ),
          );
}
