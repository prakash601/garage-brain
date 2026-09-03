import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/repositories/ownership_repository.dart';
import 'package:workshop_os/data/repositories/vehicle_repository.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  late VehicleRepository vehicles;
  late OwnershipRepository ownership;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    vehicles = VehicleRepository(db);
    ownership = OwnershipRepository(db, vehicles);
  });

  tearDown(() async => db.close());

  test('changeOwner closes old record and opens new one', () async {
    await seedCustomer(db); // c1
    await seedCustomer(db, id: 'c2', name: 'New Owner', phone: '9123456780');
    await seedVehicle(db);

    final before = await ownership.openOwnership('KA05MJ4821');
    expect(before, isNull,
        reason: 'no history row exists until first owner change');

    final opened =
        await ownership.changeOwner(numberPlate: 'KA05MJ4821', newCustomerId: 'c2');

    expect(opened.customerId, 'c2');
    expect(opened.endDate, isNull);

    final current = await vehicles.byPlate('KA05MJ4821');
    expect(current.currentCustomerId, 'c2');
  });

  test('second owner change closes the previous open record', () async {
    await seedCustomer(db);
    await seedCustomer(db, id: 'c2', name: 'B', phone: '9123456780');
    await seedCustomer(db, id: 'c3', name: 'C', phone: '9123456781');
    await seedVehicle(db);

    final first = await ownership.changeOwner(
        numberPlate: 'KA05MJ4821', newCustomerId: 'c2');
    final second = await ownership.changeOwner(
        numberPlate: 'KA05MJ4821', newCustomerId: 'c3');

    final history = await db.select(db.carOwnershipHistory).get();
    expect(history, hasLength(2));

    final closedRow = await (db.select(db.carOwnershipHistory)
          ..where((o) => o.id.equals(first.id)))
        .getSingle();
    expect(closedRow.endDate, isNotNull);

    expect(second.endDate, isNull);
    final current = await vehicles.byPlate('KA05MJ4821');
    expect(current.currentCustomerId, 'c3');
  });

  test('all writes from a change stay queued for sync', () async {
    await seedCustomer(db);
    await seedCustomer(db, id: 'c2', name: 'B', phone: '9123456780');
    await seedVehicle(db);

    await ownership.changeOwner(
        numberPlate: 'KA05MJ4821', newCustomerId: 'c2');

    final dirtyOwnership = await db.customSelect(
      'SELECT COUNT(*) AS n FROM car_ownership_history WHERE synced = 0',
    ).getSingle();
    expect(dirtyOwnership.data['n'], greaterThan(0));

    final dirtyVehicle = await db.customSelect(
      'SELECT synced FROM vehicles WHERE number_plate = ?',
      variables: [Variable.withString('KA05MJ4821')],
    ).getSingle();
    expect(dirtyVehicle.data['synced'], anyOf(0, false));
  });
}
