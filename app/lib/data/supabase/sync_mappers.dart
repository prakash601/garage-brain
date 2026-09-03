import '../drift/app_database.dart';
import '../drift/enums.dart';

/// Drift rows <-> snake_case JSON maps for the wire format. Dates travel as
/// ISO-8601 UTC strings; enums use their SQL names (see enums.dart).

String _iso(DateTime? dt) => dt?.toUtc().toIso8601String() ?? '';

Map<String, dynamic> customerToRow(Customer c) => {
      'id': c.id,
      'name': c.name,
      'phone': c.phone,
      'created_at': _iso(c.createdAt),
    };

Map<String, dynamic> vehicleToRow(Vehicle v) => {
      'number_plate': v.numberPlate,
      'vehicle_type': vehicleTypeConverter.toSql(v.vehicleType),
      'make': v.make,
      'model': v.model,
      'fuel_type': v.fuelType == null
          ? null
          : fuelTypeConverter.toSql(v.fuelType!),
      'current_customer_id': v.currentCustomerId,
      'created_at': _iso(v.createdAt),
    };

Map<String, dynamic> ownershipToRow(CarOwnershipHistoryData o) => {
      'id': o.id,
      'vehicle_number_plate': o.vehicleNumberPlate,
      'customer_id': o.customerId,
      'start_date': _iso(o.startDate),
      'end_date': _iso(o.endDate),
      'created_at': _iso(o.createdAt),
    };

Map<String, dynamic> jobCardToRow(JobCard j) => {
      'id': j.id,
      'job_no': j.jobNo,
      'vehicle_number_plate': j.vehicleNumberPlate,
      'customer_id': j.customerId,
      'km_reading': j.kmReading,
      'complaints': j.complaints,
      'status': jobStatusConverter.toSql(j.status),
      'closed': j.closed,
      'notes': j.notes,
      'created_by': j.createdBy,
      'created_at': _iso(j.createdAt),
      'updated_at': _iso(j.updatedAt),
    };

Map<String, dynamic> oldBillToRow(OldBill b) => {
      'id': b.id,
      'bill_no': b.billNo,
      'bill_date': _iso(b.billDate),
      'vehicle_number_plate': b.vehicleNumberPlate,
      'vehicle_category': vehicleTypeConverter.toSql(b.vehicleCategory),
      'customer_name': b.customerName,
      'customer_phone': b.customerPhone,
      'notes': b.notes,
      'created_at': _iso(b.createdAt),
    };

Map<String, dynamic> recommendationToRow(RecommendationQueueData r) => {
      'id': r.id,
      'customer_id': r.customerId,
      'vehicle_number_plate': r.vehicleNumberPlate,
      'type': r.type == null
          ? null
          : recommendationTypeConverter.toSql(r.type!),
      'message': r.message,
      'scheduled_for': _iso(r.scheduledFor),
      'sent': r.sent,
    };
