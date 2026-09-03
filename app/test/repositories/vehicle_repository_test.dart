import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/drift/enums.dart';
import 'package:workshop_os/data/repositories/vehicle_repository.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  late VehicleRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = VehicleRepository(db);
    await seedCustomer(db);
  });

  tearDown(() async => db.close());

  test('inserts new vehicle with normalized plate', () async {
    final v = await repo.upsertVehicle(
      numberPlate: 'KA05MJ4821',
      vehicleType: VehicleType.twoWheeler,
      make: 'Honda',
      model: 'Activa 6G',
      fuelType: FuelType.petrol,
      currentCustomerId: 'c1',
    );
    expect(v.numberPlate, 'KA05MJ4821');
    expect(v.synced, false);
  });

  test('re-registering known plate updates instead of failing', () async {
    await seedVehicle(db);

    final updated = await repo.upsertVehicle(
      numberPlate: 'KA05MJ4821',
      vehicleType: VehicleType.twoWheeler,
      make: 'Honda',
      model: 'Activa 5G',
    );

    final all = await db.select(db.vehicles).get();
    expect(all, hasLength(1));
    expect(updated.model, 'Activa 5G');
    // owner not supplied -> untouched
    expect(updated.currentCustomerId, 'c1');
    expect(updated.synced, false);
  });
}
