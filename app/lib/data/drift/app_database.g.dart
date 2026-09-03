// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    synced,
    syncedAt,
    id,
    name,
    phone,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final bool synced;
  final DateTime? syncedAt;
  final String id;
  final String name;
  final String phone;
  final DateTime createdAt;
  const Customer({
    required this.synced,
    this.syncedAt,
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['synced'] = Variable<bool>(synced);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      synced: Value(synced),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      createdAt: Value(createdAt),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      synced: serializer.fromJson<bool>(json['synced']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'synced': serializer.toJson<bool>(synced),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Customer copyWith({
    bool? synced,
    Value<DateTime?> syncedAt = const Value.absent(),
    String? id,
    String? name,
    String? phone,
    DateTime? createdAt,
  }) => Customer(
    synced: synced ?? this.synced,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    createdAt: createdAt ?? this.createdAt,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      synced: data.synced.present ? data.synced.value : this.synced,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(synced, syncedAt, id, name, phone, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.synced == this.synced &&
          other.syncedAt == this.syncedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.createdAt == this.createdAt);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<bool> synced;
  final Value<DateTime?> syncedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomersCompanion({
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    required String id,
    required String name,
    required String phone,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       phone = Value(phone);
  static Insertable<Customer> custom({
    Expression<bool>? synced,
    Expression<DateTime>? syncedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (synced != null) 'synced': synced,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<bool>? synced,
    Value<DateTime?>? syncedAt,
    Value<String>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      synced: synced ?? this.synced,
      syncedAt: syncedAt ?? this.syncedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numberPlateMeta = const VerificationMeta(
    'numberPlate',
  );
  @override
  late final GeneratedColumn<String> numberPlate = GeneratedColumn<String>(
    'number_plate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<VehicleType, String> vehicleType =
      GeneratedColumn<String>(
        'vehicle_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<VehicleType>($VehiclesTable.$convertervehicleType);
  static const VerificationMeta _makeMeta = const VerificationMeta('make');
  @override
  late final GeneratedColumn<String> make = GeneratedColumn<String>(
    'make',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FuelType?, String> fuelType =
      GeneratedColumn<String>(
        'fuel_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<FuelType?>($VehiclesTable.$converterfuelTypen);
  static const VerificationMeta _currentCustomerIdMeta = const VerificationMeta(
    'currentCustomerId',
  );
  @override
  late final GeneratedColumn<String> currentCustomerId =
      GeneratedColumn<String>(
        'current_customer_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES customers (id)',
        ),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    synced,
    syncedAt,
    numberPlate,
    vehicleType,
    make,
    model,
    fuelType,
    currentCustomerId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vehicle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('number_plate')) {
      context.handle(
        _numberPlateMeta,
        numberPlate.isAcceptableOrUnknown(
          data['number_plate']!,
          _numberPlateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_numberPlateMeta);
    }
    if (data.containsKey('make')) {
      context.handle(
        _makeMeta,
        make.isAcceptableOrUnknown(data['make']!, _makeMeta),
      );
    } else if (isInserting) {
      context.missing(_makeMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('current_customer_id')) {
      context.handle(
        _currentCustomerIdMeta,
        currentCustomerId.isAcceptableOrUnknown(
          data['current_customer_id']!,
          _currentCustomerIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {numberPlate};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      numberPlate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number_plate'],
      )!,
      vehicleType: $VehiclesTable.$convertervehicleType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}vehicle_type'],
        )!,
      ),
      make: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      fuelType: $VehiclesTable.$converterfuelTypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fuel_type'],
        ),
      ),
      currentCustomerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_customer_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }

  static TypeConverter<VehicleType, String> $convertervehicleType =
      vehicleTypeConverter;
  static TypeConverter<FuelType, String> $converterfuelType = fuelTypeConverter;
  static TypeConverter<FuelType?, String?> $converterfuelTypen =
      NullAwareTypeConverter.wrap($converterfuelType);
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final bool synced;
  final DateTime? syncedAt;
  final String numberPlate;
  final VehicleType vehicleType;
  final String make;
  final String model;
  final FuelType? fuelType;
  final String? currentCustomerId;
  final DateTime createdAt;
  const Vehicle({
    required this.synced,
    this.syncedAt,
    required this.numberPlate,
    required this.vehicleType,
    required this.make,
    required this.model,
    this.fuelType,
    this.currentCustomerId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['synced'] = Variable<bool>(synced);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['number_plate'] = Variable<String>(numberPlate);
    {
      map['vehicle_type'] = Variable<String>(
        $VehiclesTable.$convertervehicleType.toSql(vehicleType),
      );
    }
    map['make'] = Variable<String>(make);
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || fuelType != null) {
      map['fuel_type'] = Variable<String>(
        $VehiclesTable.$converterfuelTypen.toSql(fuelType),
      );
    }
    if (!nullToAbsent || currentCustomerId != null) {
      map['current_customer_id'] = Variable<String>(currentCustomerId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      synced: Value(synced),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      numberPlate: Value(numberPlate),
      vehicleType: Value(vehicleType),
      make: Value(make),
      model: Value(model),
      fuelType: fuelType == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelType),
      currentCustomerId: currentCustomerId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentCustomerId),
      createdAt: Value(createdAt),
    );
  }

  factory Vehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      synced: serializer.fromJson<bool>(json['synced']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      numberPlate: serializer.fromJson<String>(json['numberPlate']),
      vehicleType: serializer.fromJson<VehicleType>(json['vehicleType']),
      make: serializer.fromJson<String>(json['make']),
      model: serializer.fromJson<String>(json['model']),
      fuelType: serializer.fromJson<FuelType?>(json['fuelType']),
      currentCustomerId: serializer.fromJson<String?>(
        json['currentCustomerId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'synced': serializer.toJson<bool>(synced),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'numberPlate': serializer.toJson<String>(numberPlate),
      'vehicleType': serializer.toJson<VehicleType>(vehicleType),
      'make': serializer.toJson<String>(make),
      'model': serializer.toJson<String>(model),
      'fuelType': serializer.toJson<FuelType?>(fuelType),
      'currentCustomerId': serializer.toJson<String?>(currentCustomerId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Vehicle copyWith({
    bool? synced,
    Value<DateTime?> syncedAt = const Value.absent(),
    String? numberPlate,
    VehicleType? vehicleType,
    String? make,
    String? model,
    Value<FuelType?> fuelType = const Value.absent(),
    Value<String?> currentCustomerId = const Value.absent(),
    DateTime? createdAt,
  }) => Vehicle(
    synced: synced ?? this.synced,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    numberPlate: numberPlate ?? this.numberPlate,
    vehicleType: vehicleType ?? this.vehicleType,
    make: make ?? this.make,
    model: model ?? this.model,
    fuelType: fuelType.present ? fuelType.value : this.fuelType,
    currentCustomerId: currentCustomerId.present
        ? currentCustomerId.value
        : this.currentCustomerId,
    createdAt: createdAt ?? this.createdAt,
  );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      synced: data.synced.present ? data.synced.value : this.synced,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      numberPlate: data.numberPlate.present
          ? data.numberPlate.value
          : this.numberPlate,
      vehicleType: data.vehicleType.present
          ? data.vehicleType.value
          : this.vehicleType,
      make: data.make.present ? data.make.value : this.make,
      model: data.model.present ? data.model.value : this.model,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      currentCustomerId: data.currentCustomerId.present
          ? data.currentCustomerId.value
          : this.currentCustomerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('numberPlate: $numberPlate, ')
          ..write('vehicleType: $vehicleType, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('fuelType: $fuelType, ')
          ..write('currentCustomerId: $currentCustomerId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    synced,
    syncedAt,
    numberPlate,
    vehicleType,
    make,
    model,
    fuelType,
    currentCustomerId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.synced == this.synced &&
          other.syncedAt == this.syncedAt &&
          other.numberPlate == this.numberPlate &&
          other.vehicleType == this.vehicleType &&
          other.make == this.make &&
          other.model == this.model &&
          other.fuelType == this.fuelType &&
          other.currentCustomerId == this.currentCustomerId &&
          other.createdAt == this.createdAt);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<bool> synced;
  final Value<DateTime?> syncedAt;
  final Value<String> numberPlate;
  final Value<VehicleType> vehicleType;
  final Value<String> make;
  final Value<String> model;
  final Value<FuelType?> fuelType;
  final Value<String?> currentCustomerId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VehiclesCompanion({
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.numberPlate = const Value.absent(),
    this.vehicleType = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.currentCustomerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    required String numberPlate,
    required VehicleType vehicleType,
    required String make,
    required String model,
    this.fuelType = const Value.absent(),
    this.currentCustomerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : numberPlate = Value(numberPlate),
       vehicleType = Value(vehicleType),
       make = Value(make),
       model = Value(model);
  static Insertable<Vehicle> custom({
    Expression<bool>? synced,
    Expression<DateTime>? syncedAt,
    Expression<String>? numberPlate,
    Expression<String>? vehicleType,
    Expression<String>? make,
    Expression<String>? model,
    Expression<String>? fuelType,
    Expression<String>? currentCustomerId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (synced != null) 'synced': synced,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (numberPlate != null) 'number_plate': numberPlate,
      if (vehicleType != null) 'vehicle_type': vehicleType,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (fuelType != null) 'fuel_type': fuelType,
      if (currentCustomerId != null) 'current_customer_id': currentCustomerId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiclesCompanion copyWith({
    Value<bool>? synced,
    Value<DateTime?>? syncedAt,
    Value<String>? numberPlate,
    Value<VehicleType>? vehicleType,
    Value<String>? make,
    Value<String>? model,
    Value<FuelType?>? fuelType,
    Value<String?>? currentCustomerId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VehiclesCompanion(
      synced: synced ?? this.synced,
      syncedAt: syncedAt ?? this.syncedAt,
      numberPlate: numberPlate ?? this.numberPlate,
      vehicleType: vehicleType ?? this.vehicleType,
      make: make ?? this.make,
      model: model ?? this.model,
      fuelType: fuelType ?? this.fuelType,
      currentCustomerId: currentCustomerId ?? this.currentCustomerId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (numberPlate.present) {
      map['number_plate'] = Variable<String>(numberPlate.value);
    }
    if (vehicleType.present) {
      map['vehicle_type'] = Variable<String>(
        $VehiclesTable.$convertervehicleType.toSql(vehicleType.value),
      );
    }
    if (make.present) {
      map['make'] = Variable<String>(make.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(
        $VehiclesTable.$converterfuelTypen.toSql(fuelType.value),
      );
    }
    if (currentCustomerId.present) {
      map['current_customer_id'] = Variable<String>(currentCustomerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('numberPlate: $numberPlate, ')
          ..write('vehicleType: $vehicleType, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('fuelType: $fuelType, ')
          ..write('currentCustomerId: $currentCustomerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CarOwnershipHistoryTable extends CarOwnershipHistory
    with TableInfo<$CarOwnershipHistoryTable, CarOwnershipHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CarOwnershipHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleNumberPlateMeta =
      const VerificationMeta('vehicleNumberPlate');
  @override
  late final GeneratedColumn<String> vehicleNumberPlate =
      GeneratedColumn<String>(
        'vehicle_number_plate',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES vehicles (number_plate)',
        ),
      );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    synced,
    syncedAt,
    id,
    vehicleNumberPlate,
    customerId,
    startDate,
    endDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'car_ownership_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<CarOwnershipHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_number_plate')) {
      context.handle(
        _vehicleNumberPlateMeta,
        vehicleNumberPlate.isAcceptableOrUnknown(
          data['vehicle_number_plate']!,
          _vehicleNumberPlateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vehicleNumberPlateMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CarOwnershipHistoryData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CarOwnershipHistoryData(
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleNumberPlate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_number_plate'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CarOwnershipHistoryTable createAlias(String alias) {
    return $CarOwnershipHistoryTable(attachedDatabase, alias);
  }
}

class CarOwnershipHistoryData extends DataClass
    implements Insertable<CarOwnershipHistoryData> {
  final bool synced;
  final DateTime? syncedAt;
  final String id;
  final String vehicleNumberPlate;
  final String? customerId;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  const CarOwnershipHistoryData({
    required this.synced,
    this.syncedAt,
    required this.id,
    required this.vehicleNumberPlate,
    this.customerId,
    required this.startDate,
    this.endDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['synced'] = Variable<bool>(synced);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['id'] = Variable<String>(id);
    map['vehicle_number_plate'] = Variable<String>(vehicleNumberPlate);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CarOwnershipHistoryCompanion toCompanion(bool nullToAbsent) {
    return CarOwnershipHistoryCompanion(
      synced: Value(synced),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      id: Value(id),
      vehicleNumberPlate: Value(vehicleNumberPlate),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      createdAt: Value(createdAt),
    );
  }

  factory CarOwnershipHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CarOwnershipHistoryData(
      synced: serializer.fromJson<bool>(json['synced']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      id: serializer.fromJson<String>(json['id']),
      vehicleNumberPlate: serializer.fromJson<String>(
        json['vehicleNumberPlate'],
      ),
      customerId: serializer.fromJson<String?>(json['customerId']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'synced': serializer.toJson<bool>(synced),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'id': serializer.toJson<String>(id),
      'vehicleNumberPlate': serializer.toJson<String>(vehicleNumberPlate),
      'customerId': serializer.toJson<String?>(customerId),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CarOwnershipHistoryData copyWith({
    bool? synced,
    Value<DateTime?> syncedAt = const Value.absent(),
    String? id,
    String? vehicleNumberPlate,
    Value<String?> customerId = const Value.absent(),
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    DateTime? createdAt,
  }) => CarOwnershipHistoryData(
    synced: synced ?? this.synced,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    id: id ?? this.id,
    vehicleNumberPlate: vehicleNumberPlate ?? this.vehicleNumberPlate,
    customerId: customerId.present ? customerId.value : this.customerId,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    createdAt: createdAt ?? this.createdAt,
  );
  CarOwnershipHistoryData copyWithCompanion(CarOwnershipHistoryCompanion data) {
    return CarOwnershipHistoryData(
      synced: data.synced.present ? data.synced.value : this.synced,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      id: data.id.present ? data.id.value : this.id,
      vehicleNumberPlate: data.vehicleNumberPlate.present
          ? data.vehicleNumberPlate.value
          : this.vehicleNumberPlate,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CarOwnershipHistoryData(')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('vehicleNumberPlate: $vehicleNumberPlate, ')
          ..write('customerId: $customerId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    synced,
    syncedAt,
    id,
    vehicleNumberPlate,
    customerId,
    startDate,
    endDate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CarOwnershipHistoryData &&
          other.synced == this.synced &&
          other.syncedAt == this.syncedAt &&
          other.id == this.id &&
          other.vehicleNumberPlate == this.vehicleNumberPlate &&
          other.customerId == this.customerId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.createdAt == this.createdAt);
}

class CarOwnershipHistoryCompanion
    extends UpdateCompanion<CarOwnershipHistoryData> {
  final Value<bool> synced;
  final Value<DateTime?> syncedAt;
  final Value<String> id;
  final Value<String> vehicleNumberPlate;
  final Value<String?> customerId;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CarOwnershipHistoryCompanion({
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.vehicleNumberPlate = const Value.absent(),
    this.customerId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CarOwnershipHistoryCompanion.insert({
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    required String id,
    required String vehicleNumberPlate,
    this.customerId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehicleNumberPlate = Value(vehicleNumberPlate);
  static Insertable<CarOwnershipHistoryData> custom({
    Expression<bool>? synced,
    Expression<DateTime>? syncedAt,
    Expression<String>? id,
    Expression<String>? vehicleNumberPlate,
    Expression<String>? customerId,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (synced != null) 'synced': synced,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (id != null) 'id': id,
      if (vehicleNumberPlate != null)
        'vehicle_number_plate': vehicleNumberPlate,
      if (customerId != null) 'customer_id': customerId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CarOwnershipHistoryCompanion copyWith({
    Value<bool>? synced,
    Value<DateTime?>? syncedAt,
    Value<String>? id,
    Value<String>? vehicleNumberPlate,
    Value<String?>? customerId,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CarOwnershipHistoryCompanion(
      synced: synced ?? this.synced,
      syncedAt: syncedAt ?? this.syncedAt,
      id: id ?? this.id,
      vehicleNumberPlate: vehicleNumberPlate ?? this.vehicleNumberPlate,
      customerId: customerId ?? this.customerId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleNumberPlate.present) {
      map['vehicle_number_plate'] = Variable<String>(vehicleNumberPlate.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CarOwnershipHistoryCompanion(')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('vehicleNumberPlate: $vehicleNumberPlate, ')
          ..write('customerId: $customerId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JobCardsTable extends JobCards with TableInfo<$JobCardsTable, JobCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jobNoMeta = const VerificationMeta('jobNo');
  @override
  late final GeneratedColumn<int> jobNo = GeneratedColumn<int>(
    'job_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleNumberPlateMeta =
      const VerificationMeta('vehicleNumberPlate');
  @override
  late final GeneratedColumn<String> vehicleNumberPlate =
      GeneratedColumn<String>(
        'vehicle_number_plate',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES vehicles (number_plate)',
        ),
      );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _kmReadingMeta = const VerificationMeta(
    'kmReading',
  );
  @override
  late final GeneratedColumn<int> kmReading = GeneratedColumn<int>(
    'km_reading',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _complaintsMeta = const VerificationMeta(
    'complaints',
  );
  @override
  late final GeneratedColumn<String> complaints = GeneratedColumn<String>(
    'complaints',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<JobStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<JobStatus>($JobCardsTable.$converterstatus);
  static const VerificationMeta _closedMeta = const VerificationMeta('closed');
  @override
  late final GeneratedColumn<bool> closed = GeneratedColumn<bool>(
    'closed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("closed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    synced,
    syncedAt,
    id,
    jobNo,
    vehicleNumberPlate,
    customerId,
    kmReading,
    complaints,
    status,
    closed,
    notes,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('job_no')) {
      context.handle(
        _jobNoMeta,
        jobNo.isAcceptableOrUnknown(data['job_no']!, _jobNoMeta),
      );
    } else if (isInserting) {
      context.missing(_jobNoMeta);
    }
    if (data.containsKey('vehicle_number_plate')) {
      context.handle(
        _vehicleNumberPlateMeta,
        vehicleNumberPlate.isAcceptableOrUnknown(
          data['vehicle_number_plate']!,
          _vehicleNumberPlateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vehicleNumberPlateMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('km_reading')) {
      context.handle(
        _kmReadingMeta,
        kmReading.isAcceptableOrUnknown(data['km_reading']!, _kmReadingMeta),
      );
    }
    if (data.containsKey('complaints')) {
      context.handle(
        _complaintsMeta,
        complaints.isAcceptableOrUnknown(data['complaints']!, _complaintsMeta),
      );
    } else if (isInserting) {
      context.missing(_complaintsMeta);
    }
    if (data.containsKey('closed')) {
      context.handle(
        _closedMeta,
        closed.isAcceptableOrUnknown(data['closed']!, _closedMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JobCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobCard(
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jobNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}job_no'],
      )!,
      vehicleNumberPlate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_number_plate'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      kmReading: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}km_reading'],
      ),
      complaints: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}complaints'],
      )!,
      status: $JobCardsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      closed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}closed'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $JobCardsTable createAlias(String alias) {
    return $JobCardsTable(attachedDatabase, alias);
  }

  static TypeConverter<JobStatus, String> $converterstatus = jobStatusConverter;
}

class JobCard extends DataClass implements Insertable<JobCard> {
  final bool synced;
  final DateTime? syncedAt;
  final String id;
  final int jobNo;
  final String vehicleNumberPlate;
  final String customerId;
  final int? kmReading;
  final String complaints;
  final JobStatus status;
  final bool closed;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const JobCard({
    required this.synced,
    this.syncedAt,
    required this.id,
    required this.jobNo,
    required this.vehicleNumberPlate,
    required this.customerId,
    this.kmReading,
    required this.complaints,
    required this.status,
    required this.closed,
    this.notes,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['synced'] = Variable<bool>(synced);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['id'] = Variable<String>(id);
    map['job_no'] = Variable<int>(jobNo);
    map['vehicle_number_plate'] = Variable<String>(vehicleNumberPlate);
    map['customer_id'] = Variable<String>(customerId);
    if (!nullToAbsent || kmReading != null) {
      map['km_reading'] = Variable<int>(kmReading);
    }
    map['complaints'] = Variable<String>(complaints);
    {
      map['status'] = Variable<String>(
        $JobCardsTable.$converterstatus.toSql(status),
      );
    }
    map['closed'] = Variable<bool>(closed);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  JobCardsCompanion toCompanion(bool nullToAbsent) {
    return JobCardsCompanion(
      synced: Value(synced),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      id: Value(id),
      jobNo: Value(jobNo),
      vehicleNumberPlate: Value(vehicleNumberPlate),
      customerId: Value(customerId),
      kmReading: kmReading == null && nullToAbsent
          ? const Value.absent()
          : Value(kmReading),
      complaints: Value(complaints),
      status: Value(status),
      closed: Value(closed),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory JobCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobCard(
      synced: serializer.fromJson<bool>(json['synced']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      id: serializer.fromJson<String>(json['id']),
      jobNo: serializer.fromJson<int>(json['jobNo']),
      vehicleNumberPlate: serializer.fromJson<String>(
        json['vehicleNumberPlate'],
      ),
      customerId: serializer.fromJson<String>(json['customerId']),
      kmReading: serializer.fromJson<int?>(json['kmReading']),
      complaints: serializer.fromJson<String>(json['complaints']),
      status: serializer.fromJson<JobStatus>(json['status']),
      closed: serializer.fromJson<bool>(json['closed']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'synced': serializer.toJson<bool>(synced),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'id': serializer.toJson<String>(id),
      'jobNo': serializer.toJson<int>(jobNo),
      'vehicleNumberPlate': serializer.toJson<String>(vehicleNumberPlate),
      'customerId': serializer.toJson<String>(customerId),
      'kmReading': serializer.toJson<int?>(kmReading),
      'complaints': serializer.toJson<String>(complaints),
      'status': serializer.toJson<JobStatus>(status),
      'closed': serializer.toJson<bool>(closed),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  JobCard copyWith({
    bool? synced,
    Value<DateTime?> syncedAt = const Value.absent(),
    String? id,
    int? jobNo,
    String? vehicleNumberPlate,
    String? customerId,
    Value<int?> kmReading = const Value.absent(),
    String? complaints,
    JobStatus? status,
    bool? closed,
    Value<String?> notes = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => JobCard(
    synced: synced ?? this.synced,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    id: id ?? this.id,
    jobNo: jobNo ?? this.jobNo,
    vehicleNumberPlate: vehicleNumberPlate ?? this.vehicleNumberPlate,
    customerId: customerId ?? this.customerId,
    kmReading: kmReading.present ? kmReading.value : this.kmReading,
    complaints: complaints ?? this.complaints,
    status: status ?? this.status,
    closed: closed ?? this.closed,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  JobCard copyWithCompanion(JobCardsCompanion data) {
    return JobCard(
      synced: data.synced.present ? data.synced.value : this.synced,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      id: data.id.present ? data.id.value : this.id,
      jobNo: data.jobNo.present ? data.jobNo.value : this.jobNo,
      vehicleNumberPlate: data.vehicleNumberPlate.present
          ? data.vehicleNumberPlate.value
          : this.vehicleNumberPlate,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      kmReading: data.kmReading.present ? data.kmReading.value : this.kmReading,
      complaints: data.complaints.present
          ? data.complaints.value
          : this.complaints,
      status: data.status.present ? data.status.value : this.status,
      closed: data.closed.present ? data.closed.value : this.closed,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobCard(')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('jobNo: $jobNo, ')
          ..write('vehicleNumberPlate: $vehicleNumberPlate, ')
          ..write('customerId: $customerId, ')
          ..write('kmReading: $kmReading, ')
          ..write('complaints: $complaints, ')
          ..write('status: $status, ')
          ..write('closed: $closed, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    synced,
    syncedAt,
    id,
    jobNo,
    vehicleNumberPlate,
    customerId,
    kmReading,
    complaints,
    status,
    closed,
    notes,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobCard &&
          other.synced == this.synced &&
          other.syncedAt == this.syncedAt &&
          other.id == this.id &&
          other.jobNo == this.jobNo &&
          other.vehicleNumberPlate == this.vehicleNumberPlate &&
          other.customerId == this.customerId &&
          other.kmReading == this.kmReading &&
          other.complaints == this.complaints &&
          other.status == this.status &&
          other.closed == this.closed &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class JobCardsCompanion extends UpdateCompanion<JobCard> {
  final Value<bool> synced;
  final Value<DateTime?> syncedAt;
  final Value<String> id;
  final Value<int> jobNo;
  final Value<String> vehicleNumberPlate;
  final Value<String> customerId;
  final Value<int?> kmReading;
  final Value<String> complaints;
  final Value<JobStatus> status;
  final Value<bool> closed;
  final Value<String?> notes;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const JobCardsCompanion({
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.jobNo = const Value.absent(),
    this.vehicleNumberPlate = const Value.absent(),
    this.customerId = const Value.absent(),
    this.kmReading = const Value.absent(),
    this.complaints = const Value.absent(),
    this.status = const Value.absent(),
    this.closed = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobCardsCompanion.insert({
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    required String id,
    required int jobNo,
    required String vehicleNumberPlate,
    required String customerId,
    this.kmReading = const Value.absent(),
    required String complaints,
    required JobStatus status,
    this.closed = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       jobNo = Value(jobNo),
       vehicleNumberPlate = Value(vehicleNumberPlate),
       customerId = Value(customerId),
       complaints = Value(complaints),
       status = Value(status);
  static Insertable<JobCard> custom({
    Expression<bool>? synced,
    Expression<DateTime>? syncedAt,
    Expression<String>? id,
    Expression<int>? jobNo,
    Expression<String>? vehicleNumberPlate,
    Expression<String>? customerId,
    Expression<int>? kmReading,
    Expression<String>? complaints,
    Expression<String>? status,
    Expression<bool>? closed,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (synced != null) 'synced': synced,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (id != null) 'id': id,
      if (jobNo != null) 'job_no': jobNo,
      if (vehicleNumberPlate != null)
        'vehicle_number_plate': vehicleNumberPlate,
      if (customerId != null) 'customer_id': customerId,
      if (kmReading != null) 'km_reading': kmReading,
      if (complaints != null) 'complaints': complaints,
      if (status != null) 'status': status,
      if (closed != null) 'closed': closed,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobCardsCompanion copyWith({
    Value<bool>? synced,
    Value<DateTime?>? syncedAt,
    Value<String>? id,
    Value<int>? jobNo,
    Value<String>? vehicleNumberPlate,
    Value<String>? customerId,
    Value<int?>? kmReading,
    Value<String>? complaints,
    Value<JobStatus>? status,
    Value<bool>? closed,
    Value<String?>? notes,
    Value<String?>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return JobCardsCompanion(
      synced: synced ?? this.synced,
      syncedAt: syncedAt ?? this.syncedAt,
      id: id ?? this.id,
      jobNo: jobNo ?? this.jobNo,
      vehicleNumberPlate: vehicleNumberPlate ?? this.vehicleNumberPlate,
      customerId: customerId ?? this.customerId,
      kmReading: kmReading ?? this.kmReading,
      complaints: complaints ?? this.complaints,
      status: status ?? this.status,
      closed: closed ?? this.closed,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jobNo.present) {
      map['job_no'] = Variable<int>(jobNo.value);
    }
    if (vehicleNumberPlate.present) {
      map['vehicle_number_plate'] = Variable<String>(vehicleNumberPlate.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (kmReading.present) {
      map['km_reading'] = Variable<int>(kmReading.value);
    }
    if (complaints.present) {
      map['complaints'] = Variable<String>(complaints.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $JobCardsTable.$converterstatus.toSql(status.value),
      );
    }
    if (closed.present) {
      map['closed'] = Variable<bool>(closed.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobCardsCompanion(')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('jobNo: $jobNo, ')
          ..write('vehicleNumberPlate: $vehicleNumberPlate, ')
          ..write('customerId: $customerId, ')
          ..write('kmReading: $kmReading, ')
          ..write('complaints: $complaints, ')
          ..write('status: $status, ')
          ..write('closed: $closed, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OldBillsTable extends OldBills with TableInfo<$OldBillsTable, OldBill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OldBillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _billNoMeta = const VerificationMeta('billNo');
  @override
  late final GeneratedColumn<String> billNo = GeneratedColumn<String>(
    'bill_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _billDateMeta = const VerificationMeta(
    'billDate',
  );
  @override
  late final GeneratedColumn<DateTime> billDate = GeneratedColumn<DateTime>(
    'bill_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleNumberPlateMeta =
      const VerificationMeta('vehicleNumberPlate');
  @override
  late final GeneratedColumn<String> vehicleNumberPlate =
      GeneratedColumn<String>(
        'vehicle_number_plate',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES vehicles (number_plate)',
        ),
      );
  @override
  late final GeneratedColumnWithTypeConverter<VehicleType, String>
  vehicleCategory = GeneratedColumn<String>(
    'vehicle_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<VehicleType>($OldBillsTable.$convertervehicleCategory);
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerPhoneMeta = const VerificationMeta(
    'customerPhone',
  );
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
    'customer_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    synced,
    syncedAt,
    id,
    billNo,
    billDate,
    vehicleNumberPlate,
    vehicleCategory,
    customerName,
    customerPhone,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'old_bills';
  @override
  VerificationContext validateIntegrity(
    Insertable<OldBill> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bill_no')) {
      context.handle(
        _billNoMeta,
        billNo.isAcceptableOrUnknown(data['bill_no']!, _billNoMeta),
      );
    } else if (isInserting) {
      context.missing(_billNoMeta);
    }
    if (data.containsKey('bill_date')) {
      context.handle(
        _billDateMeta,
        billDate.isAcceptableOrUnknown(data['bill_date']!, _billDateMeta),
      );
    } else if (isInserting) {
      context.missing(_billDateMeta);
    }
    if (data.containsKey('vehicle_number_plate')) {
      context.handle(
        _vehicleNumberPlateMeta,
        vehicleNumberPlate.isAcceptableOrUnknown(
          data['vehicle_number_plate']!,
          _vehicleNumberPlateMeta,
        ),
      );
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
        _customerPhoneMeta,
        customerPhone.isAcceptableOrUnknown(
          data['customer_phone']!,
          _customerPhoneMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OldBill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OldBill(
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      billNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bill_no'],
      )!,
      billDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}bill_date'],
      )!,
      vehicleNumberPlate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_number_plate'],
      ),
      vehicleCategory: $OldBillsTable.$convertervehicleCategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}vehicle_category'],
        )!,
      ),
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      customerPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_phone'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OldBillsTable createAlias(String alias) {
    return $OldBillsTable(attachedDatabase, alias);
  }

  static TypeConverter<VehicleType, String> $convertervehicleCategory =
      vehicleTypeConverter;
}

class OldBill extends DataClass implements Insertable<OldBill> {
  final bool synced;
  final DateTime? syncedAt;
  final String id;
  final String billNo;
  final DateTime billDate;
  final String? vehicleNumberPlate;
  final VehicleType vehicleCategory;
  final String customerName;
  final String? customerPhone;
  final String? notes;
  final DateTime createdAt;
  const OldBill({
    required this.synced,
    this.syncedAt,
    required this.id,
    required this.billNo,
    required this.billDate,
    this.vehicleNumberPlate,
    required this.vehicleCategory,
    required this.customerName,
    this.customerPhone,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['synced'] = Variable<bool>(synced);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['id'] = Variable<String>(id);
    map['bill_no'] = Variable<String>(billNo);
    map['bill_date'] = Variable<DateTime>(billDate);
    if (!nullToAbsent || vehicleNumberPlate != null) {
      map['vehicle_number_plate'] = Variable<String>(vehicleNumberPlate);
    }
    {
      map['vehicle_category'] = Variable<String>(
        $OldBillsTable.$convertervehicleCategory.toSql(vehicleCategory),
      );
    }
    map['customer_name'] = Variable<String>(customerName);
    if (!nullToAbsent || customerPhone != null) {
      map['customer_phone'] = Variable<String>(customerPhone);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OldBillsCompanion toCompanion(bool nullToAbsent) {
    return OldBillsCompanion(
      synced: Value(synced),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      id: Value(id),
      billNo: Value(billNo),
      billDate: Value(billDate),
      vehicleNumberPlate: vehicleNumberPlate == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleNumberPlate),
      vehicleCategory: Value(vehicleCategory),
      customerName: Value(customerName),
      customerPhone: customerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(customerPhone),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory OldBill.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OldBill(
      synced: serializer.fromJson<bool>(json['synced']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      id: serializer.fromJson<String>(json['id']),
      billNo: serializer.fromJson<String>(json['billNo']),
      billDate: serializer.fromJson<DateTime>(json['billDate']),
      vehicleNumberPlate: serializer.fromJson<String?>(
        json['vehicleNumberPlate'],
      ),
      vehicleCategory: serializer.fromJson<VehicleType>(
        json['vehicleCategory'],
      ),
      customerName: serializer.fromJson<String>(json['customerName']),
      customerPhone: serializer.fromJson<String?>(json['customerPhone']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'synced': serializer.toJson<bool>(synced),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'id': serializer.toJson<String>(id),
      'billNo': serializer.toJson<String>(billNo),
      'billDate': serializer.toJson<DateTime>(billDate),
      'vehicleNumberPlate': serializer.toJson<String?>(vehicleNumberPlate),
      'vehicleCategory': serializer.toJson<VehicleType>(vehicleCategory),
      'customerName': serializer.toJson<String>(customerName),
      'customerPhone': serializer.toJson<String?>(customerPhone),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OldBill copyWith({
    bool? synced,
    Value<DateTime?> syncedAt = const Value.absent(),
    String? id,
    String? billNo,
    DateTime? billDate,
    Value<String?> vehicleNumberPlate = const Value.absent(),
    VehicleType? vehicleCategory,
    String? customerName,
    Value<String?> customerPhone = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => OldBill(
    synced: synced ?? this.synced,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    id: id ?? this.id,
    billNo: billNo ?? this.billNo,
    billDate: billDate ?? this.billDate,
    vehicleNumberPlate: vehicleNumberPlate.present
        ? vehicleNumberPlate.value
        : this.vehicleNumberPlate,
    vehicleCategory: vehicleCategory ?? this.vehicleCategory,
    customerName: customerName ?? this.customerName,
    customerPhone: customerPhone.present
        ? customerPhone.value
        : this.customerPhone,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  OldBill copyWithCompanion(OldBillsCompanion data) {
    return OldBill(
      synced: data.synced.present ? data.synced.value : this.synced,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      id: data.id.present ? data.id.value : this.id,
      billNo: data.billNo.present ? data.billNo.value : this.billNo,
      billDate: data.billDate.present ? data.billDate.value : this.billDate,
      vehicleNumberPlate: data.vehicleNumberPlate.present
          ? data.vehicleNumberPlate.value
          : this.vehicleNumberPlate,
      vehicleCategory: data.vehicleCategory.present
          ? data.vehicleCategory.value
          : this.vehicleCategory,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OldBill(')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('billNo: $billNo, ')
          ..write('billDate: $billDate, ')
          ..write('vehicleNumberPlate: $vehicleNumberPlate, ')
          ..write('vehicleCategory: $vehicleCategory, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    synced,
    syncedAt,
    id,
    billNo,
    billDate,
    vehicleNumberPlate,
    vehicleCategory,
    customerName,
    customerPhone,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OldBill &&
          other.synced == this.synced &&
          other.syncedAt == this.syncedAt &&
          other.id == this.id &&
          other.billNo == this.billNo &&
          other.billDate == this.billDate &&
          other.vehicleNumberPlate == this.vehicleNumberPlate &&
          other.vehicleCategory == this.vehicleCategory &&
          other.customerName == this.customerName &&
          other.customerPhone == this.customerPhone &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class OldBillsCompanion extends UpdateCompanion<OldBill> {
  final Value<bool> synced;
  final Value<DateTime?> syncedAt;
  final Value<String> id;
  final Value<String> billNo;
  final Value<DateTime> billDate;
  final Value<String?> vehicleNumberPlate;
  final Value<VehicleType> vehicleCategory;
  final Value<String> customerName;
  final Value<String?> customerPhone;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OldBillsCompanion({
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.billNo = const Value.absent(),
    this.billDate = const Value.absent(),
    this.vehicleNumberPlate = const Value.absent(),
    this.vehicleCategory = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OldBillsCompanion.insert({
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    required String id,
    required String billNo,
    required DateTime billDate,
    this.vehicleNumberPlate = const Value.absent(),
    required VehicleType vehicleCategory,
    required String customerName,
    this.customerPhone = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       billNo = Value(billNo),
       billDate = Value(billDate),
       vehicleCategory = Value(vehicleCategory),
       customerName = Value(customerName);
  static Insertable<OldBill> custom({
    Expression<bool>? synced,
    Expression<DateTime>? syncedAt,
    Expression<String>? id,
    Expression<String>? billNo,
    Expression<DateTime>? billDate,
    Expression<String>? vehicleNumberPlate,
    Expression<String>? vehicleCategory,
    Expression<String>? customerName,
    Expression<String>? customerPhone,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (synced != null) 'synced': synced,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (id != null) 'id': id,
      if (billNo != null) 'bill_no': billNo,
      if (billDate != null) 'bill_date': billDate,
      if (vehicleNumberPlate != null)
        'vehicle_number_plate': vehicleNumberPlate,
      if (vehicleCategory != null) 'vehicle_category': vehicleCategory,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OldBillsCompanion copyWith({
    Value<bool>? synced,
    Value<DateTime?>? syncedAt,
    Value<String>? id,
    Value<String>? billNo,
    Value<DateTime>? billDate,
    Value<String?>? vehicleNumberPlate,
    Value<VehicleType>? vehicleCategory,
    Value<String>? customerName,
    Value<String?>? customerPhone,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return OldBillsCompanion(
      synced: synced ?? this.synced,
      syncedAt: syncedAt ?? this.syncedAt,
      id: id ?? this.id,
      billNo: billNo ?? this.billNo,
      billDate: billDate ?? this.billDate,
      vehicleNumberPlate: vehicleNumberPlate ?? this.vehicleNumberPlate,
      vehicleCategory: vehicleCategory ?? this.vehicleCategory,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (billNo.present) {
      map['bill_no'] = Variable<String>(billNo.value);
    }
    if (billDate.present) {
      map['bill_date'] = Variable<DateTime>(billDate.value);
    }
    if (vehicleNumberPlate.present) {
      map['vehicle_number_plate'] = Variable<String>(vehicleNumberPlate.value);
    }
    if (vehicleCategory.present) {
      map['vehicle_category'] = Variable<String>(
        $OldBillsTable.$convertervehicleCategory.toSql(vehicleCategory.value),
      );
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OldBillsCompanion(')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('billNo: $billNo, ')
          ..write('billDate: $billDate, ')
          ..write('vehicleNumberPlate: $vehicleNumberPlate, ')
          ..write('vehicleCategory: $vehicleCategory, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecommendationQueueTable extends RecommendationQueue
    with TableInfo<$RecommendationQueueTable, RecommendationQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecommendationQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _vehicleNumberPlateMeta =
      const VerificationMeta('vehicleNumberPlate');
  @override
  late final GeneratedColumn<String> vehicleNumberPlate =
      GeneratedColumn<String>(
        'vehicle_number_plate',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES vehicles (number_plate)',
        ),
      );
  @override
  late final GeneratedColumnWithTypeConverter<RecommendationType?, String>
  type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<RecommendationType?>(
        $RecommendationQueueTable.$convertertypen,
      );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledForMeta = const VerificationMeta(
    'scheduledFor',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledFor = GeneratedColumn<DateTime>(
    'scheduled_for',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sentMeta = const VerificationMeta('sent');
  @override
  late final GeneratedColumn<bool> sent = GeneratedColumn<bool>(
    'sent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sent" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    synced,
    syncedAt,
    id,
    customerId,
    vehicleNumberPlate,
    type,
    message,
    scheduledFor,
    sent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recommendation_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecommendationQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('vehicle_number_plate')) {
      context.handle(
        _vehicleNumberPlateMeta,
        vehicleNumberPlate.isAcceptableOrUnknown(
          data['vehicle_number_plate']!,
          _vehicleNumberPlateMeta,
        ),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('scheduled_for')) {
      context.handle(
        _scheduledForMeta,
        scheduledFor.isAcceptableOrUnknown(
          data['scheduled_for']!,
          _scheduledForMeta,
        ),
      );
    }
    if (data.containsKey('sent')) {
      context.handle(
        _sentMeta,
        sent.isAcceptableOrUnknown(data['sent']!, _sentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecommendationQueueData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecommendationQueueData(
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      vehicleNumberPlate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_number_plate'],
      ),
      type: $RecommendationQueueTable.$convertertypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        ),
      ),
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      scheduledFor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_for'],
      ),
      sent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sent'],
      )!,
    );
  }

  @override
  $RecommendationQueueTable createAlias(String alias) {
    return $RecommendationQueueTable(attachedDatabase, alias);
  }

  static TypeConverter<RecommendationType, String> $convertertype =
      recommendationTypeConverter;
  static TypeConverter<RecommendationType?, String?> $convertertypen =
      NullAwareTypeConverter.wrap($convertertype);
}

class RecommendationQueueData extends DataClass
    implements Insertable<RecommendationQueueData> {
  final bool synced;
  final DateTime? syncedAt;
  final String id;
  final String? customerId;
  final String? vehicleNumberPlate;
  final RecommendationType? type;
  final String message;
  final DateTime? scheduledFor;
  final bool sent;
  const RecommendationQueueData({
    required this.synced,
    this.syncedAt,
    required this.id,
    this.customerId,
    this.vehicleNumberPlate,
    this.type,
    required this.message,
    this.scheduledFor,
    required this.sent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['synced'] = Variable<bool>(synced);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || vehicleNumberPlate != null) {
      map['vehicle_number_plate'] = Variable<String>(vehicleNumberPlate);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(
        $RecommendationQueueTable.$convertertypen.toSql(type),
      );
    }
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || scheduledFor != null) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor);
    }
    map['sent'] = Variable<bool>(sent);
    return map;
  }

  RecommendationQueueCompanion toCompanion(bool nullToAbsent) {
    return RecommendationQueueCompanion(
      synced: Value(synced),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      id: Value(id),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      vehicleNumberPlate: vehicleNumberPlate == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleNumberPlate),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      message: Value(message),
      scheduledFor: scheduledFor == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledFor),
      sent: Value(sent),
    );
  }

  factory RecommendationQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecommendationQueueData(
      synced: serializer.fromJson<bool>(json['synced']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      vehicleNumberPlate: serializer.fromJson<String?>(
        json['vehicleNumberPlate'],
      ),
      type: serializer.fromJson<RecommendationType?>(json['type']),
      message: serializer.fromJson<String>(json['message']),
      scheduledFor: serializer.fromJson<DateTime?>(json['scheduledFor']),
      sent: serializer.fromJson<bool>(json['sent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'synced': serializer.toJson<bool>(synced),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String?>(customerId),
      'vehicleNumberPlate': serializer.toJson<String?>(vehicleNumberPlate),
      'type': serializer.toJson<RecommendationType?>(type),
      'message': serializer.toJson<String>(message),
      'scheduledFor': serializer.toJson<DateTime?>(scheduledFor),
      'sent': serializer.toJson<bool>(sent),
    };
  }

  RecommendationQueueData copyWith({
    bool? synced,
    Value<DateTime?> syncedAt = const Value.absent(),
    String? id,
    Value<String?> customerId = const Value.absent(),
    Value<String?> vehicleNumberPlate = const Value.absent(),
    Value<RecommendationType?> type = const Value.absent(),
    String? message,
    Value<DateTime?> scheduledFor = const Value.absent(),
    bool? sent,
  }) => RecommendationQueueData(
    synced: synced ?? this.synced,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    id: id ?? this.id,
    customerId: customerId.present ? customerId.value : this.customerId,
    vehicleNumberPlate: vehicleNumberPlate.present
        ? vehicleNumberPlate.value
        : this.vehicleNumberPlate,
    type: type.present ? type.value : this.type,
    message: message ?? this.message,
    scheduledFor: scheduledFor.present ? scheduledFor.value : this.scheduledFor,
    sent: sent ?? this.sent,
  );
  RecommendationQueueData copyWithCompanion(RecommendationQueueCompanion data) {
    return RecommendationQueueData(
      synced: data.synced.present ? data.synced.value : this.synced,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      vehicleNumberPlate: data.vehicleNumberPlate.present
          ? data.vehicleNumberPlate.value
          : this.vehicleNumberPlate,
      type: data.type.present ? data.type.value : this.type,
      message: data.message.present ? data.message.value : this.message,
      scheduledFor: data.scheduledFor.present
          ? data.scheduledFor.value
          : this.scheduledFor,
      sent: data.sent.present ? data.sent.value : this.sent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecommendationQueueData(')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('vehicleNumberPlate: $vehicleNumberPlate, ')
          ..write('type: $type, ')
          ..write('message: $message, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('sent: $sent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    synced,
    syncedAt,
    id,
    customerId,
    vehicleNumberPlate,
    type,
    message,
    scheduledFor,
    sent,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecommendationQueueData &&
          other.synced == this.synced &&
          other.syncedAt == this.syncedAt &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.vehicleNumberPlate == this.vehicleNumberPlate &&
          other.type == this.type &&
          other.message == this.message &&
          other.scheduledFor == this.scheduledFor &&
          other.sent == this.sent);
}

class RecommendationQueueCompanion
    extends UpdateCompanion<RecommendationQueueData> {
  final Value<bool> synced;
  final Value<DateTime?> syncedAt;
  final Value<String> id;
  final Value<String?> customerId;
  final Value<String?> vehicleNumberPlate;
  final Value<RecommendationType?> type;
  final Value<String> message;
  final Value<DateTime?> scheduledFor;
  final Value<bool> sent;
  final Value<int> rowid;
  const RecommendationQueueCompanion({
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.vehicleNumberPlate = const Value.absent(),
    this.type = const Value.absent(),
    this.message = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    this.sent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecommendationQueueCompanion.insert({
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    required String id,
    this.customerId = const Value.absent(),
    this.vehicleNumberPlate = const Value.absent(),
    this.type = const Value.absent(),
    required String message,
    this.scheduledFor = const Value.absent(),
    this.sent = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       message = Value(message);
  static Insertable<RecommendationQueueData> custom({
    Expression<bool>? synced,
    Expression<DateTime>? syncedAt,
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? vehicleNumberPlate,
    Expression<String>? type,
    Expression<String>? message,
    Expression<DateTime>? scheduledFor,
    Expression<bool>? sent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (synced != null) 'synced': synced,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (vehicleNumberPlate != null)
        'vehicle_number_plate': vehicleNumberPlate,
      if (type != null) 'type': type,
      if (message != null) 'message': message,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
      if (sent != null) 'sent': sent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecommendationQueueCompanion copyWith({
    Value<bool>? synced,
    Value<DateTime?>? syncedAt,
    Value<String>? id,
    Value<String?>? customerId,
    Value<String?>? vehicleNumberPlate,
    Value<RecommendationType?>? type,
    Value<String>? message,
    Value<DateTime?>? scheduledFor,
    Value<bool>? sent,
    Value<int>? rowid,
  }) {
    return RecommendationQueueCompanion(
      synced: synced ?? this.synced,
      syncedAt: syncedAt ?? this.syncedAt,
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      vehicleNumberPlate: vehicleNumberPlate ?? this.vehicleNumberPlate,
      type: type ?? this.type,
      message: message ?? this.message,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      sent: sent ?? this.sent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (vehicleNumberPlate.present) {
      map['vehicle_number_plate'] = Variable<String>(vehicleNumberPlate.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $RecommendationQueueTable.$convertertypen.toSql(type.value),
      );
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (scheduledFor.present) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor.value);
    }
    if (sent.present) {
      map['sent'] = Variable<bool>(sent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecommendationQueueCompanion(')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('vehicleNumberPlate: $vehicleNumberPlate, ')
          ..write('type: $type, ')
          ..write('message: $message, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('sent: $sent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $CarOwnershipHistoryTable carOwnershipHistory =
      $CarOwnershipHistoryTable(this);
  late final $JobCardsTable jobCards = $JobCardsTable(this);
  late final $OldBillsTable oldBills = $OldBillsTable(this);
  late final $RecommendationQueueTable recommendationQueue =
      $RecommendationQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customers,
    vehicles,
    carOwnershipHistory,
    jobCards,
    oldBills,
    recommendationQueue,
  ];
}

typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  Value<bool> synced,
  Value<DateTime?> syncedAt,
  required String id,
  required String name,
  required String phone,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<bool> synced,
  Value<DateTime?> syncedAt,
  Value<String> id,
  Value<String> name,
  Value<String> phone,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, Customer> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VehiclesTable, List<Vehicle>> _vehiclesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.vehicles,
    aliasName: 'customers__id__vehicles__current_customer_id',
  );

  $$VehiclesTableProcessedTableManager get vehiclesRefs {
    final manager = $$VehiclesTableTableManager($_db, $_db.vehicles).filter(
      (f) => f.currentCustomerId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_vehiclesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CarOwnershipHistoryTable,
    List<CarOwnershipHistoryData>
  >
  _carOwnershipHistoryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.carOwnershipHistory,
        aliasName: 'customers__id__car_ownership_history__customer_id',
      );

  $$CarOwnershipHistoryTableProcessedTableManager get carOwnershipHistoryRefs {
    final manager = $$CarOwnershipHistoryTableTableManager(
      $_db,
      $_db.carOwnershipHistory,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _carOwnershipHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$JobCardsTable, List<JobCard>> _jobCardsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jobCards,
    aliasName: 'customers__id__job_cards__customer_id',
  );

  $$JobCardsTableProcessedTableManager get jobCardsRefs {
    final manager = $$JobCardsTableTableManager(
      $_db,
      $_db.jobCards,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_jobCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecommendationQueueTable,
    List<RecommendationQueueData>
  >
  _recommendationQueueRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recommendationQueue,
        aliasName: 'customers__id__recommendation_queue__customer_id',
      );

  $$RecommendationQueueTableProcessedTableManager get recommendationQueueRefs {
    final manager = $$RecommendationQueueTableTableManager(
      $_db,
      $_db.recommendationQueue,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recommendationQueueRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> vehiclesRefs(
    Expression<bool> Function($$VehiclesTableFilterComposer f) f,
  ) {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.currentCustomerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> carOwnershipHistoryRefs(
    Expression<bool> Function($$CarOwnershipHistoryTableFilterComposer f) f,
  ) {
    final $$CarOwnershipHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.carOwnershipHistory,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarOwnershipHistoryTableFilterComposer(
            $db: $db,
            $table: $db.carOwnershipHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> jobCardsRefs(
    Expression<bool> Function($$JobCardsTableFilterComposer f) f,
  ) {
    final $$JobCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobCards,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobCardsTableFilterComposer(
            $db: $db,
            $table: $db.jobCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recommendationQueueRefs(
    Expression<bool> Function($$RecommendationQueueTableFilterComposer f) f,
  ) {
    final $$RecommendationQueueTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recommendationQueue,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecommendationQueueTableFilterComposer(
            $db: $db,
            $table: $db.recommendationQueue,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> vehiclesRefs<T extends Object>(
    Expression<T> Function($$VehiclesTableAnnotationComposer a) f,
  ) {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.currentCustomerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> carOwnershipHistoryRefs<T extends Object>(
    Expression<T> Function($$CarOwnershipHistoryTableAnnotationComposer a) f,
  ) {
    final $$CarOwnershipHistoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.carOwnershipHistory,
          getReferencedColumn: (t) => t.customerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CarOwnershipHistoryTableAnnotationComposer(
                $db: $db,
                $table: $db.carOwnershipHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> jobCardsRefs<T extends Object>(
    Expression<T> Function($$JobCardsTableAnnotationComposer a) f,
  ) {
    final $$JobCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobCards,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recommendationQueueRefs<T extends Object>(
    Expression<T> Function($$RecommendationQueueTableAnnotationComposer a) f,
  ) {
    final $$RecommendationQueueTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recommendationQueue,
          getReferencedColumn: (t) => t.customerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecommendationQueueTableAnnotationComposer(
                $db: $db,
                $table: $db.recommendationQueue,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, $$CustomersTableReferences),
          Customer,
          PrefetchHooks Function({
            bool vehiclesRefs,
            bool carOwnershipHistoryRefs,
            bool jobCardsRefs,
            bool recommendationQueueRefs,
          })
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> synced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                synced: synced,
                syncedAt: syncedAt,
                id: id,
                name: name,
                phone: phone,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> synced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                required String id,
                required String name,
                required String phone,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                synced: synced,
                syncedAt: syncedAt,
                id: id,
                name: name,
                phone: phone,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                vehiclesRefs = false,
                carOwnershipHistoryRefs = false,
                jobCardsRefs = false,
                recommendationQueueRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (vehiclesRefs) db.vehicles,
                    if (carOwnershipHistoryRefs) db.carOwnershipHistory,
                    if (jobCardsRefs) db.jobCards,
                    if (recommendationQueueRefs) db.recommendationQueue,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (vehiclesRefs)
                        await $_getPrefetchedData<
                          Customer,
                          $CustomersTable,
                          Vehicle
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._vehiclesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).vehiclesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.currentCustomerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (carOwnershipHistoryRefs)
                        await $_getPrefetchedData<
                          Customer,
                          $CustomersTable,
                          CarOwnershipHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._carOwnershipHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).carOwnershipHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (jobCardsRefs)
                        await $_getPrefetchedData<
                          Customer,
                          $CustomersTable,
                          JobCard
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._jobCardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).jobCardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recommendationQueueRefs)
                        await $_getPrefetchedData<
                          Customer,
                          $CustomersTable,
                          RecommendationQueueData
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._recommendationQueueRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).recommendationQueueRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, $$CustomersTableReferences),
      Customer,
      PrefetchHooks Function({
        bool vehiclesRefs,
        bool carOwnershipHistoryRefs,
        bool jobCardsRefs,
        bool recommendationQueueRefs,
      })
    >;
typedef $$VehiclesTableCreateCompanionBuilder = VehiclesCompanion Function({
  Value<bool> synced,
  Value<DateTime?> syncedAt,
  required String numberPlate,
  required VehicleType vehicleType,
  required String make,
  required String model,
  Value<FuelType?> fuelType,
  Value<String?> currentCustomerId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$VehiclesTableUpdateCompanionBuilder = VehiclesCompanion Function({
  Value<bool> synced,
  Value<DateTime?> syncedAt,
  Value<String> numberPlate,
  Value<VehicleType> vehicleType,
  Value<String> make,
  Value<String> model,
  Value<FuelType?> fuelType,
  Value<String?> currentCustomerId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _currentCustomerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('vehicles__current_customer_id__customers__id');

  $$CustomersTableProcessedTableManager? get currentCustomerId {
    final $_column = $_itemColumn<String>('current_customer_id');
    if ($_column == null) return null;
    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currentCustomerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $CarOwnershipHistoryTable,
    List<CarOwnershipHistoryData>
  >
  _carOwnershipHistoryRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.carOwnershipHistory,
    aliasName:
        'vehicles__number_plate__car_ownership_history__vehicle_number_plate',
  );

  $$CarOwnershipHistoryTableProcessedTableManager get carOwnershipHistoryRefs {
    final manager =
        $$CarOwnershipHistoryTableTableManager(
          $_db,
          $_db.carOwnershipHistory,
        ).filter(
          (f) => f.vehicleNumberPlate.numberPlate.sqlEquals(
            $_itemColumn<String>('number_plate')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _carOwnershipHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$JobCardsTable, List<JobCard>> _jobCardsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jobCards,
    aliasName: 'vehicles__number_plate__job_cards__vehicle_number_plate',
  );

  $$JobCardsTableProcessedTableManager get jobCardsRefs {
    final manager = $$JobCardsTableTableManager($_db, $_db.jobCards).filter(
      (f) => f.vehicleNumberPlate.numberPlate.sqlEquals(
        $_itemColumn<String>('number_plate')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_jobCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OldBillsTable, List<OldBill>> _oldBillsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.oldBills,
    aliasName: 'vehicles__number_plate__old_bills__vehicle_number_plate',
  );

  $$OldBillsTableProcessedTableManager get oldBillsRefs {
    final manager = $$OldBillsTableTableManager($_db, $_db.oldBills).filter(
      (f) => f.vehicleNumberPlate.numberPlate.sqlEquals(
        $_itemColumn<String>('number_plate')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_oldBillsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecommendationQueueTable,
    List<RecommendationQueueData>
  >
  _recommendationQueueRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.recommendationQueue,
    aliasName:
        'vehicles__number_plate__recommendation_queue__vehicle_number_plate',
  );

  $$RecommendationQueueTableProcessedTableManager get recommendationQueueRefs {
    final manager =
        $$RecommendationQueueTableTableManager(
          $_db,
          $_db.recommendationQueue,
        ).filter(
          (f) => f.vehicleNumberPlate.numberPlate.sqlEquals(
            $_itemColumn<String>('number_plate')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _recommendationQueueRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numberPlate => $composableBuilder(
    column: $table.numberPlate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<VehicleType, VehicleType, String>
  get vehicleType => $composableBuilder(
    column: $table.vehicleType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FuelType?, FuelType, String> get fuelType =>
      $composableBuilder(
        column: $table.fuelType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get currentCustomerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentCustomerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> carOwnershipHistoryRefs(
    Expression<bool> Function($$CarOwnershipHistoryTableFilterComposer f) f,
  ) {
    final $$CarOwnershipHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.numberPlate,
      referencedTable: $db.carOwnershipHistory,
      getReferencedColumn: (t) => t.vehicleNumberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarOwnershipHistoryTableFilterComposer(
            $db: $db,
            $table: $db.carOwnershipHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> jobCardsRefs(
    Expression<bool> Function($$JobCardsTableFilterComposer f) f,
  ) {
    final $$JobCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.numberPlate,
      referencedTable: $db.jobCards,
      getReferencedColumn: (t) => t.vehicleNumberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobCardsTableFilterComposer(
            $db: $db,
            $table: $db.jobCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> oldBillsRefs(
    Expression<bool> Function($$OldBillsTableFilterComposer f) f,
  ) {
    final $$OldBillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.numberPlate,
      referencedTable: $db.oldBills,
      getReferencedColumn: (t) => t.vehicleNumberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OldBillsTableFilterComposer(
            $db: $db,
            $table: $db.oldBills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recommendationQueueRefs(
    Expression<bool> Function($$RecommendationQueueTableFilterComposer f) f,
  ) {
    final $$RecommendationQueueTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.numberPlate,
      referencedTable: $db.recommendationQueue,
      getReferencedColumn: (t) => t.vehicleNumberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecommendationQueueTableFilterComposer(
            $db: $db,
            $table: $db.recommendationQueue,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numberPlate => $composableBuilder(
    column: $table.numberPlate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleType => $composableBuilder(
    column: $table.vehicleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get currentCustomerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentCustomerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get numberPlate => $composableBuilder(
    column: $table.numberPlate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<VehicleType, String> get vehicleType =>
      $composableBuilder(
        column: $table.vehicleType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get make =>
      $composableBuilder(column: $table.make, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FuelType?, String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get currentCustomerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentCustomerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> carOwnershipHistoryRefs<T extends Object>(
    Expression<T> Function($$CarOwnershipHistoryTableAnnotationComposer a) f,
  ) {
    final $$CarOwnershipHistoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.numberPlate,
          referencedTable: $db.carOwnershipHistory,
          getReferencedColumn: (t) => t.vehicleNumberPlate,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CarOwnershipHistoryTableAnnotationComposer(
                $db: $db,
                $table: $db.carOwnershipHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> jobCardsRefs<T extends Object>(
    Expression<T> Function($$JobCardsTableAnnotationComposer a) f,
  ) {
    final $$JobCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.numberPlate,
      referencedTable: $db.jobCards,
      getReferencedColumn: (t) => t.vehicleNumberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> oldBillsRefs<T extends Object>(
    Expression<T> Function($$OldBillsTableAnnotationComposer a) f,
  ) {
    final $$OldBillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.numberPlate,
      referencedTable: $db.oldBills,
      getReferencedColumn: (t) => t.vehicleNumberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OldBillsTableAnnotationComposer(
            $db: $db,
            $table: $db.oldBills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recommendationQueueRefs<T extends Object>(
    Expression<T> Function($$RecommendationQueueTableAnnotationComposer a) f,
  ) {
    final $$RecommendationQueueTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.numberPlate,
          referencedTable: $db.recommendationQueue,
          getReferencedColumn: (t) => t.vehicleNumberPlate,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecommendationQueueTableAnnotationComposer(
                $db: $db,
                $table: $db.recommendationQueue,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          Vehicle,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (Vehicle, $$VehiclesTableReferences),
          Vehicle,
          PrefetchHooks Function({
            bool currentCustomerId,
            bool carOwnershipHistoryRefs,
            bool jobCardsRefs,
            bool oldBillsRefs,
            bool recommendationQueueRefs,
          })
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> synced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<String> numberPlate = const Value.absent(),
                Value<VehicleType> vehicleType = const Value.absent(),
                Value<String> make = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<FuelType?> fuelType = const Value.absent(),
                Value<String?> currentCustomerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion(
                synced: synced,
                syncedAt: syncedAt,
                numberPlate: numberPlate,
                vehicleType: vehicleType,
                make: make,
                model: model,
                fuelType: fuelType,
                currentCustomerId: currentCustomerId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> synced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                required String numberPlate,
                required VehicleType vehicleType,
                required String make,
                required String model,
                Value<FuelType?> fuelType = const Value.absent(),
                Value<String?> currentCustomerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion.insert(
                synced: synced,
                syncedAt: syncedAt,
                numberPlate: numberPlate,
                vehicleType: vehicleType,
                make: make,
                model: model,
                fuelType: fuelType,
                currentCustomerId: currentCustomerId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                currentCustomerId = false,
                carOwnershipHistoryRefs = false,
                jobCardsRefs = false,
                oldBillsRefs = false,
                recommendationQueueRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (carOwnershipHistoryRefs) db.carOwnershipHistory,
                    if (jobCardsRefs) db.jobCards,
                    if (oldBillsRefs) db.oldBills,
                    if (recommendationQueueRefs) db.recommendationQueue,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (currentCustomerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.currentCustomerId,
                            referencedTable: $$VehiclesTableReferences
                                ._currentCustomerIdTable(db),
                            referencedColumn: $$VehiclesTableReferences
                                ._currentCustomerIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (carOwnershipHistoryRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          CarOwnershipHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._carOwnershipHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).carOwnershipHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleNumberPlate == item.numberPlate,
                              ),
                          typedResults: items,
                        ),
                      if (jobCardsRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          JobCard
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._jobCardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).jobCardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleNumberPlate == item.numberPlate,
                              ),
                          typedResults: items,
                        ),
                      if (oldBillsRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          OldBill
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._oldBillsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).oldBillsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleNumberPlate == item.numberPlate,
                              ),
                          typedResults: items,
                        ),
                      if (recommendationQueueRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          RecommendationQueueData
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._recommendationQueueRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).recommendationQueueRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleNumberPlate == item.numberPlate,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      Vehicle,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (Vehicle, $$VehiclesTableReferences),
      Vehicle,
      PrefetchHooks Function({
        bool currentCustomerId,
        bool carOwnershipHistoryRefs,
        bool jobCardsRefs,
        bool oldBillsRefs,
        bool recommendationQueueRefs,
      })
    >;
typedef $$CarOwnershipHistoryTableCreateCompanionBuilder =
    CarOwnershipHistoryCompanion Function({
      Value<bool> synced,
      Value<DateTime?> syncedAt,
      required String id,
      required String vehicleNumberPlate,
      Value<String?> customerId,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$CarOwnershipHistoryTableUpdateCompanionBuilder =
    CarOwnershipHistoryCompanion Function({
      Value<bool> synced,
      Value<DateTime?> syncedAt,
      Value<String> id,
      Value<String> vehicleNumberPlate,
      Value<String?> customerId,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CarOwnershipHistoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CarOwnershipHistoryTable,
          CarOwnershipHistoryData
        > {
  $$CarOwnershipHistoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehiclesTable _vehicleNumberPlateTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
        'car_ownership_history__vehicle_number_plate__vehicles__number_plate',
      );

  $$VehiclesTableProcessedTableManager get vehicleNumberPlate {
    final $_column = $_itemColumn<String>('vehicle_number_plate')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.numberPlate.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleNumberPlateTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomersTable _customerIdTable(_$AppDatabase db) => db.customers
      .createAlias('car_ownership_history__customer_id__customers__id');

  $$CustomersTableProcessedTableManager? get customerId {
    final $_column = $_itemColumn<String>('customer_id');
    if ($_column == null) return null;
    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CarOwnershipHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $CarOwnershipHistoryTable> {
  $$CarOwnershipHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleNumberPlate {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleNumberPlate,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.numberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CarOwnershipHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $CarOwnershipHistoryTable> {
  $$CarOwnershipHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleNumberPlate {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleNumberPlate,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.numberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CarOwnershipHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $CarOwnershipHistoryTable> {
  $$CarOwnershipHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleNumberPlate {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleNumberPlate,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.numberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CarOwnershipHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CarOwnershipHistoryTable,
          CarOwnershipHistoryData,
          $$CarOwnershipHistoryTableFilterComposer,
          $$CarOwnershipHistoryTableOrderingComposer,
          $$CarOwnershipHistoryTableAnnotationComposer,
          $$CarOwnershipHistoryTableCreateCompanionBuilder,
          $$CarOwnershipHistoryTableUpdateCompanionBuilder,
          (CarOwnershipHistoryData, $$CarOwnershipHistoryTableReferences),
          CarOwnershipHistoryData,
          PrefetchHooks Function({bool vehicleNumberPlate, bool customerId})
        > {
  $$CarOwnershipHistoryTableTableManager(
    _$AppDatabase db,
    $CarOwnershipHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CarOwnershipHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CarOwnershipHistoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CarOwnershipHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<bool> synced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> vehicleNumberPlate = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CarOwnershipHistoryCompanion(
                synced: synced,
                syncedAt: syncedAt,
                id: id,
                vehicleNumberPlate: vehicleNumberPlate,
                customerId: customerId,
                startDate: startDate,
                endDate: endDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> synced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                required String id,
                required String vehicleNumberPlate,
                Value<String?> customerId = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CarOwnershipHistoryCompanion.insert(
                synced: synced,
                syncedAt: syncedAt,
                id: id,
                vehicleNumberPlate: vehicleNumberPlate,
                customerId: customerId,
                startDate: startDate,
                endDate: endDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CarOwnershipHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({vehicleNumberPlate = false, customerId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (vehicleNumberPlate) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.vehicleNumberPlate,
                            referencedTable:
                                $$CarOwnershipHistoryTableReferences
                                    ._vehicleNumberPlateTable(db),
                            referencedColumn:
                                $$CarOwnershipHistoryTableReferences
                                    ._vehicleNumberPlateTable(db)
                                    .numberPlate,
                          ) as T;
                        }
                        if (customerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.customerId,
                            referencedTable:
                                $$CarOwnershipHistoryTableReferences
                                    ._customerIdTable(db),
                            referencedColumn:
                                $$CarOwnershipHistoryTableReferences
                                    ._customerIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$CarOwnershipHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CarOwnershipHistoryTable,
      CarOwnershipHistoryData,
      $$CarOwnershipHistoryTableFilterComposer,
      $$CarOwnershipHistoryTableOrderingComposer,
      $$CarOwnershipHistoryTableAnnotationComposer,
      $$CarOwnershipHistoryTableCreateCompanionBuilder,
      $$CarOwnershipHistoryTableUpdateCompanionBuilder,
      (CarOwnershipHistoryData, $$CarOwnershipHistoryTableReferences),
      CarOwnershipHistoryData,
      PrefetchHooks Function({bool vehicleNumberPlate, bool customerId})
    >;
typedef $$JobCardsTableCreateCompanionBuilder = JobCardsCompanion Function({
  Value<bool> synced,
  Value<DateTime?> syncedAt,
  required String id,
  required int jobNo,
  required String vehicleNumberPlate,
  required String customerId,
  Value<int?> kmReading,
  required String complaints,
  required JobStatus status,
  Value<bool> closed,
  Value<String?> notes,
  Value<String?> createdBy,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$JobCardsTableUpdateCompanionBuilder = JobCardsCompanion Function({
  Value<bool> synced,
  Value<DateTime?> syncedAt,
  Value<String> id,
  Value<int> jobNo,
  Value<String> vehicleNumberPlate,
  Value<String> customerId,
  Value<int?> kmReading,
  Value<String> complaints,
  Value<JobStatus> status,
  Value<bool> closed,
  Value<String?> notes,
  Value<String?> createdBy,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$JobCardsTableReferences
    extends BaseReferences<_$AppDatabase, $JobCardsTable, JobCard> {
  $$JobCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleNumberPlateTable(_$AppDatabase db) => db
      .vehicles
      .createAlias('job_cards__vehicle_number_plate__vehicles__number_plate');

  $$VehiclesTableProcessedTableManager get vehicleNumberPlate {
    final $_column = $_itemColumn<String>('vehicle_number_plate')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.numberPlate.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleNumberPlateTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('job_cards__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$JobCardsTableFilterComposer
    extends Composer<_$AppDatabase, $JobCardsTable> {
  $$JobCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jobNo => $composableBuilder(
    column: $table.jobNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kmReading => $composableBuilder(
    column: $table.kmReading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get complaints => $composableBuilder(
    column: $table.complaints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<JobStatus, JobStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get closed => $composableBuilder(
    column: $table.closed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleNumberPlate {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleNumberPlate,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.numberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $JobCardsTable> {
  $$JobCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jobNo => $composableBuilder(
    column: $table.jobNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kmReading => $composableBuilder(
    column: $table.kmReading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get complaints => $composableBuilder(
    column: $table.complaints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get closed => $composableBuilder(
    column: $table.closed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleNumberPlate {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleNumberPlate,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.numberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobCardsTable> {
  $$JobCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jobNo =>
      $composableBuilder(column: $table.jobNo, builder: (column) => column);

  GeneratedColumn<int> get kmReading =>
      $composableBuilder(column: $table.kmReading, builder: (column) => column);

  GeneratedColumn<String> get complaints => $composableBuilder(
    column: $table.complaints,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<JobStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get closed =>
      $composableBuilder(column: $table.closed, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleNumberPlate {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleNumberPlate,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.numberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobCardsTable,
          JobCard,
          $$JobCardsTableFilterComposer,
          $$JobCardsTableOrderingComposer,
          $$JobCardsTableAnnotationComposer,
          $$JobCardsTableCreateCompanionBuilder,
          $$JobCardsTableUpdateCompanionBuilder,
          (JobCard, $$JobCardsTableReferences),
          JobCard,
          PrefetchHooks Function({bool vehicleNumberPlate, bool customerId})
        > {
  $$JobCardsTableTableManager(_$AppDatabase db, $JobCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> synced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> jobNo = const Value.absent(),
                Value<String> vehicleNumberPlate = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<int?> kmReading = const Value.absent(),
                Value<String> complaints = const Value.absent(),
                Value<JobStatus> status = const Value.absent(),
                Value<bool> closed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobCardsCompanion(
                synced: synced,
                syncedAt: syncedAt,
                id: id,
                jobNo: jobNo,
                vehicleNumberPlate: vehicleNumberPlate,
                customerId: customerId,
                kmReading: kmReading,
                complaints: complaints,
                status: status,
                closed: closed,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> synced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                required String id,
                required int jobNo,
                required String vehicleNumberPlate,
                required String customerId,
                Value<int?> kmReading = const Value.absent(),
                required String complaints,
                required JobStatus status,
                Value<bool> closed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobCardsCompanion.insert(
                synced: synced,
                syncedAt: syncedAt,
                id: id,
                jobNo: jobNo,
                vehicleNumberPlate: vehicleNumberPlate,
                customerId: customerId,
                kmReading: kmReading,
                complaints: complaints,
                status: status,
                closed: closed,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JobCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({vehicleNumberPlate = false, customerId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (vehicleNumberPlate) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.vehicleNumberPlate,
                            referencedTable: $$JobCardsTableReferences
                                ._vehicleNumberPlateTable(db),
                            referencedColumn: $$JobCardsTableReferences
                                ._vehicleNumberPlateTable(db)
                                .numberPlate,
                          ) as T;
                        }
                        if (customerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.customerId,
                            referencedTable: $$JobCardsTableReferences
                                ._customerIdTable(db),
                            referencedColumn: $$JobCardsTableReferences
                                ._customerIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$JobCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobCardsTable,
      JobCard,
      $$JobCardsTableFilterComposer,
      $$JobCardsTableOrderingComposer,
      $$JobCardsTableAnnotationComposer,
      $$JobCardsTableCreateCompanionBuilder,
      $$JobCardsTableUpdateCompanionBuilder,
      (JobCard, $$JobCardsTableReferences),
      JobCard,
      PrefetchHooks Function({bool vehicleNumberPlate, bool customerId})
    >;
typedef $$OldBillsTableCreateCompanionBuilder = OldBillsCompanion Function({
  Value<bool> synced,
  Value<DateTime?> syncedAt,
  required String id,
  required String billNo,
  required DateTime billDate,
  Value<String?> vehicleNumberPlate,
  required VehicleType vehicleCategory,
  required String customerName,
  Value<String?> customerPhone,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$OldBillsTableUpdateCompanionBuilder = OldBillsCompanion Function({
  Value<bool> synced,
  Value<DateTime?> syncedAt,
  Value<String> id,
  Value<String> billNo,
  Value<DateTime> billDate,
  Value<String?> vehicleNumberPlate,
  Value<VehicleType> vehicleCategory,
  Value<String> customerName,
  Value<String?> customerPhone,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$OldBillsTableReferences
    extends BaseReferences<_$AppDatabase, $OldBillsTable, OldBill> {
  $$OldBillsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleNumberPlateTable(_$AppDatabase db) => db
      .vehicles
      .createAlias('old_bills__vehicle_number_plate__vehicles__number_plate');

  $$VehiclesTableProcessedTableManager? get vehicleNumberPlate {
    final $_column = $_itemColumn<String>('vehicle_number_plate');
    if ($_column == null) return null;
    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.numberPlate.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleNumberPlateTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OldBillsTableFilterComposer
    extends Composer<_$AppDatabase, $OldBillsTable> {
  $$OldBillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billNo => $composableBuilder(
    column: $table.billNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get billDate => $composableBuilder(
    column: $table.billDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<VehicleType, VehicleType, String>
  get vehicleCategory => $composableBuilder(
    column: $table.vehicleCategory,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleNumberPlate {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleNumberPlate,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.numberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OldBillsTableOrderingComposer
    extends Composer<_$AppDatabase, $OldBillsTable> {
  $$OldBillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billNo => $composableBuilder(
    column: $table.billNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get billDate => $composableBuilder(
    column: $table.billDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleCategory => $composableBuilder(
    column: $table.vehicleCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleNumberPlate {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleNumberPlate,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.numberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OldBillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OldBillsTable> {
  $$OldBillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get billNo =>
      $composableBuilder(column: $table.billNo, builder: (column) => column);

  GeneratedColumn<DateTime> get billDate =>
      $composableBuilder(column: $table.billDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<VehicleType, String> get vehicleCategory =>
      $composableBuilder(
        column: $table.vehicleCategory,
        builder: (column) => column,
      );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleNumberPlate {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleNumberPlate,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.numberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OldBillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OldBillsTable,
          OldBill,
          $$OldBillsTableFilterComposer,
          $$OldBillsTableOrderingComposer,
          $$OldBillsTableAnnotationComposer,
          $$OldBillsTableCreateCompanionBuilder,
          $$OldBillsTableUpdateCompanionBuilder,
          (OldBill, $$OldBillsTableReferences),
          OldBill,
          PrefetchHooks Function({bool vehicleNumberPlate})
        > {
  $$OldBillsTableTableManager(_$AppDatabase db, $OldBillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OldBillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OldBillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OldBillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> synced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> billNo = const Value.absent(),
                Value<DateTime> billDate = const Value.absent(),
                Value<String?> vehicleNumberPlate = const Value.absent(),
                Value<VehicleType> vehicleCategory = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String?> customerPhone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OldBillsCompanion(
                synced: synced,
                syncedAt: syncedAt,
                id: id,
                billNo: billNo,
                billDate: billDate,
                vehicleNumberPlate: vehicleNumberPlate,
                vehicleCategory: vehicleCategory,
                customerName: customerName,
                customerPhone: customerPhone,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> synced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                required String id,
                required String billNo,
                required DateTime billDate,
                Value<String?> vehicleNumberPlate = const Value.absent(),
                required VehicleType vehicleCategory,
                required String customerName,
                Value<String?> customerPhone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OldBillsCompanion.insert(
                synced: synced,
                syncedAt: syncedAt,
                id: id,
                billNo: billNo,
                billDate: billDate,
                vehicleNumberPlate: vehicleNumberPlate,
                vehicleCategory: vehicleCategory,
                customerName: customerName,
                customerPhone: customerPhone,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OldBillsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleNumberPlate = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleNumberPlate) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.vehicleNumberPlate,
                        referencedTable: $$OldBillsTableReferences
                            ._vehicleNumberPlateTable(db),
                        referencedColumn: $$OldBillsTableReferences
                            ._vehicleNumberPlateTable(db)
                            .numberPlate,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OldBillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OldBillsTable,
      OldBill,
      $$OldBillsTableFilterComposer,
      $$OldBillsTableOrderingComposer,
      $$OldBillsTableAnnotationComposer,
      $$OldBillsTableCreateCompanionBuilder,
      $$OldBillsTableUpdateCompanionBuilder,
      (OldBill, $$OldBillsTableReferences),
      OldBill,
      PrefetchHooks Function({bool vehicleNumberPlate})
    >;
typedef $$RecommendationQueueTableCreateCompanionBuilder =
    RecommendationQueueCompanion Function({
      Value<bool> synced,
      Value<DateTime?> syncedAt,
      required String id,
      Value<String?> customerId,
      Value<String?> vehicleNumberPlate,
      Value<RecommendationType?> type,
      required String message,
      Value<DateTime?> scheduledFor,
      Value<bool> sent,
      Value<int> rowid,
    });
typedef $$RecommendationQueueTableUpdateCompanionBuilder =
    RecommendationQueueCompanion Function({
      Value<bool> synced,
      Value<DateTime?> syncedAt,
      Value<String> id,
      Value<String?> customerId,
      Value<String?> vehicleNumberPlate,
      Value<RecommendationType?> type,
      Value<String> message,
      Value<DateTime?> scheduledFor,
      Value<bool> sent,
      Value<int> rowid,
    });

final class $$RecommendationQueueTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecommendationQueueTable,
          RecommendationQueueData
        > {
  $$RecommendationQueueTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomersTable _customerIdTable(_$AppDatabase db) => db.customers
      .createAlias('recommendation_queue__customer_id__customers__id');

  $$CustomersTableProcessedTableManager? get customerId {
    final $_column = $_itemColumn<String>('customer_id');
    if ($_column == null) return null;
    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VehiclesTable _vehicleNumberPlateTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
        'recommendation_queue__vehicle_number_plate__vehicles__number_plate',
      );

  $$VehiclesTableProcessedTableManager? get vehicleNumberPlate {
    final $_column = $_itemColumn<String>('vehicle_number_plate');
    if ($_column == null) return null;
    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.numberPlate.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleNumberPlateTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecommendationQueueTableFilterComposer
    extends Composer<_$AppDatabase, $RecommendationQueueTable> {
  $$RecommendationQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    RecommendationType?,
    RecommendationType,
    String
  >
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sent => $composableBuilder(
    column: $table.sent,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableFilterComposer get vehicleNumberPlate {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleNumberPlate,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.numberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecommendationQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $RecommendationQueueTable> {
  $$RecommendationQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sent => $composableBuilder(
    column: $table.sent,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableOrderingComposer get vehicleNumberPlate {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleNumberPlate,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.numberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecommendationQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecommendationQueueTable> {
  $$RecommendationQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecommendationType?, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sent =>
      $composableBuilder(column: $table.sent, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableAnnotationComposer get vehicleNumberPlate {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleNumberPlate,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.numberPlate,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecommendationQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecommendationQueueTable,
          RecommendationQueueData,
          $$RecommendationQueueTableFilterComposer,
          $$RecommendationQueueTableOrderingComposer,
          $$RecommendationQueueTableAnnotationComposer,
          $$RecommendationQueueTableCreateCompanionBuilder,
          $$RecommendationQueueTableUpdateCompanionBuilder,
          (RecommendationQueueData, $$RecommendationQueueTableReferences),
          RecommendationQueueData,
          PrefetchHooks Function({bool customerId, bool vehicleNumberPlate})
        > {
  $$RecommendationQueueTableTableManager(
    _$AppDatabase db,
    $RecommendationQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecommendationQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecommendationQueueTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecommendationQueueTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<bool> synced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String?> vehicleNumberPlate = const Value.absent(),
                Value<RecommendationType?> type = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<DateTime?> scheduledFor = const Value.absent(),
                Value<bool> sent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecommendationQueueCompanion(
                synced: synced,
                syncedAt: syncedAt,
                id: id,
                customerId: customerId,
                vehicleNumberPlate: vehicleNumberPlate,
                type: type,
                message: message,
                scheduledFor: scheduledFor,
                sent: sent,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> synced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                required String id,
                Value<String?> customerId = const Value.absent(),
                Value<String?> vehicleNumberPlate = const Value.absent(),
                Value<RecommendationType?> type = const Value.absent(),
                required String message,
                Value<DateTime?> scheduledFor = const Value.absent(),
                Value<bool> sent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecommendationQueueCompanion.insert(
                synced: synced,
                syncedAt: syncedAt,
                id: id,
                customerId: customerId,
                vehicleNumberPlate: vehicleNumberPlate,
                type: type,
                message: message,
                scheduledFor: scheduledFor,
                sent: sent,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecommendationQueueTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({customerId = false, vehicleNumberPlate = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (customerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.customerId,
                            referencedTable:
                                $$RecommendationQueueTableReferences
                                    ._customerIdTable(db),
                            referencedColumn:
                                $$RecommendationQueueTableReferences
                                    ._customerIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (vehicleNumberPlate) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.vehicleNumberPlate,
                            referencedTable:
                                $$RecommendationQueueTableReferences
                                    ._vehicleNumberPlateTable(db),
                            referencedColumn:
                                $$RecommendationQueueTableReferences
                                    ._vehicleNumberPlateTable(db)
                                    .numberPlate,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$RecommendationQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecommendationQueueTable,
      RecommendationQueueData,
      $$RecommendationQueueTableFilterComposer,
      $$RecommendationQueueTableOrderingComposer,
      $$RecommendationQueueTableAnnotationComposer,
      $$RecommendationQueueTableCreateCompanionBuilder,
      $$RecommendationQueueTableUpdateCompanionBuilder,
      (RecommendationQueueData, $$RecommendationQueueTableReferences),
      RecommendationQueueData,
      PrefetchHooks Function({bool customerId, bool vehicleNumberPlate})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$CarOwnershipHistoryTableTableManager get carOwnershipHistory =>
      $$CarOwnershipHistoryTableTableManager(_db, _db.carOwnershipHistory);
  $$JobCardsTableTableManager get jobCards =>
      $$JobCardsTableTableManager(_db, _db.jobCards);
  $$OldBillsTableTableManager get oldBills =>
      $$OldBillsTableTableManager(_db, _db.oldBills);
  $$RecommendationQueueTableTableManager get recommendationQueue =>
      $$RecommendationQueueTableTableManager(_db, _db.recommendationQueue);
}
