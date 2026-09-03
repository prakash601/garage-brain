import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../drift/app_database.dart';
import 'vehicle_repository.dart';

/// Close-old/open-new semantics on owner change (DESIGN.md §5):
/// the vehicle's open ownership row gets `end_date = now`, a fresh row opens
/// for the new owner, and `vehicles.current_customer_id` is repointed.
class OwnershipRepository {
  OwnershipRepository(this._db, this._vehicles, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final VehicleRepository _vehicles;
  final Uuid _uuid;

  Future<CarOwnershipHistoryData> changeOwner({
    required String numberPlate,
    required String newCustomerId,
    DateTime? at,
  }) async {
    final when = at ?? DateTime.now();

    return _db.transaction(() async {
      await (_db.update(_db.carOwnershipHistory)
            ..where((o) =>
                o.vehicleNumberPlate.equals(numberPlate) &
                o.endDate.isNull()))
          .write(CarOwnershipHistoryCompanion(
        endDate: Value(when),
        synced: const Value(false),
        syncedAt: const Value(null),
      ));

      final opened =
          await _db.into(_db.carOwnershipHistory).insertReturning(
                CarOwnershipHistoryCompanion.insert(
                  id: _uuid.v4(),
                  vehicleNumberPlate: numberPlate,
                  customerId: Value(newCustomerId),
                  startDate: Value(when),
                  endDate: const Value(null),
                ),
              );

      await _vehicles.setCurrentCustomer(numberPlate, newCustomerId);
      return opened;
    });
  }

  /// Currently open ownership row for a plate, if any.
  Future<CarOwnershipHistoryData?> openOwnership(String numberPlate) =>
      (_db.select(_db.carOwnershipHistory)
            ..where((o) =>
                o.vehicleNumberPlate.equals(numberPlate) &
                o.endDate.isNull()))
          .getSingleOrNull();
}
