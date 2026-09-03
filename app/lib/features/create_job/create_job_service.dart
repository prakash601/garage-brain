import 'package:drift/drift.dart';

import '../../core/utils/phone.dart';
import '../../core/utils/plate.dart';
import '../../core/utils/validators.dart';
import '../../data/drift/app_database.dart';
import '../../data/drift/enums.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/job_repository.dart';
import '../../data/repositories/ownership_repository.dart';
import '../../data/repositories/vehicle_repository.dart';

class CreateJobValidationException implements Exception {
  CreateJobValidationException(this.errors);

  final Map<String, String> errors;

  @override
  String toString() => errors.values.join(', ');
}

/// Orchestrates the S4 single flow: customer upsert (phone = identity),
/// vehicle upsert with ownership trail maintenance, job insert — all local
/// Drift writes with synced=false so the UI confirms instantly offline
/// (DESIGN.md §6 S4, §7).
class CreateJobService {
  CreateJobService(AppDatabase db)
      : _db = db,
        _vehicles = VehicleRepository(db),
        _jobs = JobRepository(db) {
    _ownership = OwnershipRepository(db, _vehicles);
    _customers = CustomerRepository(db, ownershipRepository: _ownership);
  }

  final AppDatabase _db;
  final VehicleRepository _vehicles;
  final JobRepository _jobs;
  late final OwnershipRepository _ownership;
  late final CustomerRepository _customers;

  Map<String, String> validate({
    required String plate,
    required String make,
    required String model,
    required String name,
    required String phone,
    required String complaints,
  }) {
    final errors = <String, String>{};
    final flag = classifyPlate(plate);
    if (flag == PlateFlag.red || plate.length < 6) {
      errors['plate'] = 'Enter a valid plate (letters and digits)';
    }
    if (make.trim().isEmpty) errors['make'] = 'Select a make';
    if (model.trim().isEmpty) errors['model'] = 'Enter the model';
    if (!isValidCustomerName(name)) {
      errors['name'] = 'Enter the customer name';
    }
    if (!isValidPhone(normalizePhone(phone))) {
      errors['phone'] = 'Enter a valid 10-digit mobile number';
    }
    if (complaints.trim().isEmpty) {
      errors['complaints'] = 'Describe the complaint';
    }
    return errors;
  }

  Future<Customer?> findCustomerByPhone(String phone) =>
      _customers.findByPhone(phone);

  Future<Vehicle?> findVehicleByPlate(String plate) =>
      _vehicles.findPlate(plate);

  Future<Customer?> findCustomerById(String id) async {
    final rows = await (_db.select(_db.customers)
          ..where((c) => c.id.equals(id))
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.single;
  }

  /// An already-open job for this plate usually means a duplicate entry
  /// (receptionist forgot the vehicle is already in the shop).
  Future<JobCard?> findOpenJobByPlate(String plate) =>
      (_db.select(_db.jobCards)
            ..where((j) =>
                j.vehicleNumberPlate.equals(plate) &
                j.closed.equals(false))
            ..orderBy([(j) => OrderingTerm.desc(j.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<JobCard> createJob({
    required String plate,
    required VehicleType vehicleType,
    required String make,
    required String model,
    FuelType? fuelType,
    required String name,
    required String phone,
    required String complaints,
    int? kmReading,
  }) async {
    final errors = validate(
      plate: plate,
      make: make,
      model: model,
      name: name,
      phone: phone,
      complaints: complaints,
    );
    if (errors.isNotEmpty) throw CreateJobValidationException(errors);

    final customer = await _customers.upsertByNameAndPhone(
      name: name.trim(),
      phone: normalizePhone(phone),
    );
    final existingVehicle =
        await _vehicles.findPlate(plate);
    await _vehicles.upsertVehicle(
      numberPlate: plate,
      vehicleType: vehicleType,
      make: make,
      model: model.trim(),
      fuelType: fuelType,
      currentCustomerId: existingVehicle?.currentCustomerId,
    );

    // Owner change goes through the ownership trail (close-old/open-new).
    if (existingVehicle?.currentCustomerId != customer.id) {
      await _ownership.changeOwner(
        numberPlate: plate,
        newCustomerId: customer.id,
      );
    }

    return _jobs.createJob(
      vehicleNumberPlate: plate,
      customerId: customer.id,
      complaints: complaints.trim(),
      kmReading: kmReading,
    );
  }
}
