import 'package:drift/drift.dart';

enum VehicleType { twoWheeler, fourWheeler }

enum FuelType { petrol, diesel, cng, electric, hybrid }

enum JobStatus { arrived, inProgress, readyForDelivery, delivered }

enum RecommendationType { serviceDue, churn, offer }

String vehicleTypeLabel(VehicleType type) =>
    type == VehicleType.twoWheeler ? '2W' : '4W';

class SqlEnumConverter<T extends Enum> extends TypeConverter<T, String> {
  const SqlEnumConverter(this.values, this.sqlNames);

  final List<T> values;
  final List<String> sqlNames;

  @override
  T fromSql(String dbValue) {
    final index = sqlNames.indexOf(dbValue);
    if (index == -1) {
      throw ArgumentError.value(dbValue, 'dbValue', 'unknown $T value');
    }
    return values[index];
  }

  @override
  String toSql(T value) => sqlNames[value.index];
}

const vehicleTypeConverter =
    SqlEnumConverter<VehicleType>(VehicleType.values, ['2W', '4W']);

const fuelTypeConverter = SqlEnumConverter<FuelType>(
  FuelType.values,
  ['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid'],
);

const jobStatusConverter = SqlEnumConverter<JobStatus>(
  JobStatus.values,
  ['Arrived', 'InProgress', 'ReadyForDelivery', 'Delivered'],
);

const recommendationTypeConverter = SqlEnumConverter<RecommendationType>(
  RecommendationType.values,
  ['service_due', 'churn', 'offer'],
);
