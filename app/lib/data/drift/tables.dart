import 'package:drift/drift.dart';

import 'enums.dart';

mixin SyncColumns on Table {
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  DateTimeColumn get syncedAt => dateTime().nullable()();
}

class Customers extends Table with SyncColumns {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get phone => text().unique()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Vehicles extends Table with SyncColumns {
  TextColumn get numberPlate => text()();

  TextColumn get vehicleType => text().map(vehicleTypeConverter)();

  TextColumn get make => text()();

  TextColumn get model => text()();

  TextColumn get fuelType => text().nullable().map(fuelTypeConverter)();

  TextColumn get currentCustomerId =>
      text().nullable().references(Customers, #id)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {numberPlate};
}

class CarOwnershipHistory extends Table with SyncColumns {
  TextColumn get id => text()();

  TextColumn get vehicleNumberPlate =>
      text().references(Vehicles, #numberPlate)();

  TextColumn get customerId => text().nullable().references(Customers, #id)();

  DateTimeColumn get startDate =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get endDate => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class JobCards extends Table with SyncColumns {
  TextColumn get id => text()();

  IntColumn get jobNo => integer()();

  TextColumn get vehicleNumberPlate =>
      text().references(Vehicles, #numberPlate)();

  TextColumn get customerId => text().references(Customers, #id)();

  IntColumn get kmReading => integer().nullable()();

  TextColumn get complaints => text()();

  TextColumn get status => text().map(jobStatusConverter)();

  BoolColumn get closed => boolean().withDefault(const Constant(false))();

  TextColumn get notes => text().nullable()();

  TextColumn get createdBy => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class OldBills extends Table with SyncColumns {
  TextColumn get id => text()();

  TextColumn get billNo => text().unique()();

  DateTimeColumn get billDate => dateTime()();

  TextColumn get vehicleNumberPlate =>
      text().nullable().references(Vehicles, #numberPlate)();

  TextColumn get vehicleCategory => text().map(vehicleTypeConverter)();

  TextColumn get customerName => text()();

  TextColumn get customerPhone => text().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class RecommendationQueue extends Table with SyncColumns {
  TextColumn get id => text()();

  TextColumn get customerId => text().nullable().references(Customers, #id)();

  TextColumn get vehicleNumberPlate =>
      text().nullable().references(Vehicles, #numberPlate)();

  TextColumn get type =>
      text().nullable().map(recommendationTypeConverter)();

  TextColumn get message => text()();

  DateTimeColumn get scheduledFor => dateTime().nullable()();

  BoolColumn get sent => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
