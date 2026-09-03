import 'package:drift/drift.dart';

import '../drift/app_database.dart';
import '../drift/enums.dart';

class VehicleRepository {
  VehicleRepository(this._db);

  final AppDatabase _db;

  Future<Vehicle> byPlate(String plate) =>
      (_db.select(_db.vehicles)..where((v) => v.numberPlate.equals(plate)))
          .getSingle();

  Future<Vehicle?> findPlate(String plate) =>
      (_db.select(_db.vehicles)..where((v) => v.numberPlate.equals(plate)))
          .getSingleOrNull();

  /// Plates are natural PKs (already normalized upstream); re-registering a
  /// known plate updates it rather than failing.
  Future<Vehicle> upsertVehicle({
    required String numberPlate,
    required VehicleType vehicleType,
    required String make,
    required String model,
    FuelType? fuelType,
    String? currentCustomerId,
  }) async {
    final existing = await findPlate(numberPlate);
    if (existing != null) {
      final rows = await (_db.update(_db.vehicles)
            ..where((v) => v.numberPlate.equals(numberPlate)))
          .writeReturning(
        VehiclesCompanion(
          vehicleType: Value(vehicleType),
          make: Value(make),
          model: Value(model),
          // absent-if-null: an update must never silently clear these
          fuelType: fuelType != null ? Value(fuelType) : const Value.absent(),
          currentCustomerId: currentCustomerId != null
              ? Value(currentCustomerId)
              : const Value.absent(),
          synced: const Value(false),
          syncedAt: const Value(null),
        ),
      );
      return rows.single;
    }
    return _db.into(_db.vehicles).insertReturning(
          VehiclesCompanion.insert(
            numberPlate: numberPlate,
            vehicleType: vehicleType,
            make: make,
            model: model,
            fuelType: Value(fuelType),
            currentCustomerId: Value(currentCustomerId),
          ),
        );
  }

  /// Owner changes must go through [OwnershipRepository.changeOwner] so the
  /// history stays consistent (close-old/open-new).
  Future<void> setCurrentCustomer(String plate, String customerId) async {
    await (_db.update(_db.vehicles)
          ..where((v) => v.numberPlate.equals(plate)))
        .write(VehiclesCompanion(
      currentCustomerId: Value(customerId),
      synced: const Value(false),
      syncedAt: const Value(null),
    ));
  }
}
