import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../drift/app_database.dart';
import '../drift/enums.dart';

class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  Future<Map<String, dynamic>> buildExportJson() async {
    final customers = await _db.select(_db.customers).get();
    final vehicles = await _db.select(_db.vehicles).get();
    final history = await _db.select(_db.carOwnershipHistory).get();
    final jobs = await _db.select(_db.jobCards).get();
    final oldBills = await _db.select(_db.oldBills).get();
    final recs = await _db.select(_db.recommendationQueue).get();

    String iso(DateTime? dt) => dt?.toUtc().toIso8601String() ?? '';

    return {
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'version': 1,
      'tables': {
        'customers': [
          for (final c in customers)
            {
              'id': c.id,
              'name': c.name,
              'phone': c.phone,
              'created_at': iso(c.createdAt),
              'synced': c.synced,
              'synced_at': c.syncedAt == null ? null : iso(c.syncedAt),
            }
        ],
        'vehicles': [
          for (final v in vehicles)
            {
              'number_plate': v.numberPlate,
              'vehicle_type': vehicleTypeConverter.toSql(v.vehicleType),
              'make': v.make,
              'model': v.model,
              'fuel_type': v.fuelType == null
                  ? null
                  : fuelTypeConverter.toSql(v.fuelType!),
              'current_customer_id': v.currentCustomerId,
              'created_at': iso(v.createdAt),
              'synced': v.synced,
              'synced_at': v.syncedAt == null ? null : iso(v.syncedAt),
            }
        ],
        'car_ownership_history': [
          for (final h in history)
            {
              'id': h.id,
              'vehicle_number_plate': h.vehicleNumberPlate,
              'customer_id': h.customerId,
              'start_date': iso(h.startDate),
              'end_date': h.endDate == null ? null : iso(h.endDate),
              'created_at': iso(h.createdAt),
              'synced': h.synced,
              'synced_at': h.syncedAt == null ? null : iso(h.syncedAt),
            }
        ],
        'job_cards': [
          for (final j in jobs)
            {
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
              'created_at': iso(j.createdAt),
              'updated_at': iso(j.updatedAt),
              'synced': j.synced,
              'synced_at': j.syncedAt == null ? null : iso(j.syncedAt),
            }
        ],
        'old_bills': [
          for (final b in oldBills)
            {
              'id': b.id,
              'bill_no': b.billNo,
              'bill_date': iso(b.billDate),
              'vehicle_number_plate': b.vehicleNumberPlate,
              'vehicle_category':
                  vehicleTypeConverter.toSql(b.vehicleCategory),
              'customer_name': b.customerName,
              'customer_phone': b.customerPhone,
              'notes': b.notes,
              'created_at': iso(b.createdAt),
              'synced': b.synced,
              'synced_at': b.syncedAt == null ? null : iso(b.syncedAt),
            }
        ],
        'recommendation_queue': [
          for (final r in recs)
            {
              'id': r.id,
              'customer_id': r.customerId,
              'vehicle_number_plate': r.vehicleNumberPlate,
              'type': r.type == null
                  ? null
                  : recommendationTypeConverter.toSql(r.type!),
              'message': r.message,
              'scheduled_for':
                  r.scheduledFor == null ? null : iso(r.scheduledFor),
              'sent': r.sent,
              'synced': r.synced,
              'synced_at': r.syncedAt == null ? null : iso(r.syncedAt),
            }
        ],
      },
    };
  }

  Future<String> exportJsonString() async {
    final map = await buildExportJson();
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  Future<File> writeExportFile({
    String? directoryPath,
    String? fileName,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('File export not supported on web; '
          'use exportJsonString and trigger a browser download');
    }
    final jsonStr = await exportJsonString();
    final dir = directoryPath != null
        ? Directory(directoryPath)
        : await _backupDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final name = fileName ?? 'workshop_os_export_${_timestamp()}.json';
    final file = File('${dir.path}/$name');
    await file.writeAsString(jsonStr, encoding: utf8);
    return file;
  }

  Future<File?> copyDatabaseFile({String? directoryPath}) async {
    if (kIsWeb) return null;
    final source = await _findDatabaseFile();
    if (source == null || !await source.exists()) return null;
    final targetDir = directoryPath != null
        ? Directory(directoryPath)
        : await _backupDirectory();
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    final target =
        File('${targetDir.path}/workshop_os_backup_${_timestamp()}.sqlite');
    await source.copy(target.path);
    return target;
  }

  Future<Directory> _backupDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    return Directory('${base.path}/backups');
  }

  Future<File?> _findDatabaseFile() async {
    final candidates = <Directory>[];
    try {
      candidates.add(await getApplicationSupportDirectory());
    } catch (_) {}
    try {
      candidates.add(await getApplicationDocumentsDirectory());
    } catch (_) {}
    try {
      candidates.add(await getTemporaryDirectory());
    } catch (_) {}
    const names = ['workshop_os.sqlite', 'workshop_os', 'workshop_os.db'];
    for (final dir in candidates) {
      for (final name in names) {
        final f = File('${dir.path}/$name');
        if (await f.exists()) return f;
      }
      try {
        final entries = await dir.list().toList();
        for (final e in entries) {
          if (e is File &&
              e.path.contains('workshop_os') &&
              await e.exists()) {
            final stat = await e.stat();
            if (stat.size > 0) return e;
          }
        }
      } catch (_) {}
    }
    return null;
  }

  String _timestamp() {
    final now = DateTime.now().toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}_'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }

  Future<void> restoreFromJson(Map<String, dynamic> json) async {
    final tables = json['tables'] as Map<String, dynamic>?;
    if (tables == null) return;

    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      if (v is String && v.isEmpty) return null;
      return DateTime.tryParse(v as String);
    }

    final customers = tables['customers'] as List<dynamic>? ?? [];
    for (final raw in customers) {
      final m = Map<String, dynamic>.from(raw as Map);
      final id = m['id'] as String;
      await _db.into(_db.customers).insertOnConflictUpdate(
            CustomersCompanion.insert(
              id: id,
              name: m['name'] as String,
              phone: m['phone'] as String,
              createdAt: Value(parseDt(m['created_at']) ?? DateTime.now()),
            ),
          );
    }

    final vehicles = tables['vehicles'] as List<dynamic>? ?? [];
    for (final raw in vehicles) {
      final m = Map<String, dynamic>.from(raw as Map);
      final plate = m['number_plate'] as String;
      final vt = m['vehicle_type'] as String;
      final fuelRaw = m['fuel_type'] as String?;
      await _db.into(_db.vehicles).insertOnConflictUpdate(
            VehiclesCompanion.insert(
              numberPlate: plate,
              vehicleType: vehicleTypeConverter.fromSql(vt),
              make: m['make'] as String,
              model: m['model'] as String,
              fuelType: Value(fuelRaw == null ? null : fuelTypeConverter.fromSql(fuelRaw)),
              currentCustomerId: Value(m['current_customer_id'] as String?),
              createdAt: Value(parseDt(m['created_at']) ?? DateTime.now()),
            ),
          );
    }

    final histories = tables['car_ownership_history'] as List<dynamic>? ?? [];
    for (final raw in histories) {
      final m = Map<String, dynamic>.from(raw as Map);
      await _db.into(_db.carOwnershipHistory).insertOnConflictUpdate(
            CarOwnershipHistoryCompanion.insert(
              id: m['id'] as String,
              vehicleNumberPlate: m['vehicle_number_plate'] as String,
              customerId: Value(m['customer_id'] as String?),
              startDate: Value(parseDt(m['start_date']) ?? DateTime.now()),
              endDate: Value(parseDt(m['end_date'])),
              createdAt: Value(parseDt(m['created_at']) ?? DateTime.now()),
            ),
          );
    }

    final jobs = tables['job_cards'] as List<dynamic>? ?? [];
    for (final raw in jobs) {
      final m = Map<String, dynamic>.from(raw as Map);
      await _db.into(_db.jobCards).insertOnConflictUpdate(
            JobCardsCompanion.insert(
              id: m['id'] as String,
              jobNo: (m['job_no'] as num).toInt(),
              vehicleNumberPlate: m['vehicle_number_plate'] as String,
              customerId: m['customer_id'] as String,
              complaints: m['complaints'] as String,
              status: jobStatusConverter.fromSql(m['status'] as String),
              kmReading: Value(m['km_reading'] as int?),
              notes: Value(m['notes'] as String?),
              closed: Value(m['closed'] as bool? ?? false),
              createdBy: Value(m['created_by'] as String?),
              createdAt: Value(parseDt(m['created_at']) ?? DateTime.now()),
              updatedAt: Value(parseDt(m['updated_at']) ?? DateTime.now()),
            ),
          );
    }

    final bills = tables['old_bills'] as List<dynamic>? ?? [];
    for (final raw in bills) {
      final m = Map<String, dynamic>.from(raw as Map);
      await _db.into(_db.oldBills).insertOnConflictUpdate(
            OldBillsCompanion.insert(
              id: m['id'] as String,
              billNo: m['bill_no'] as String,
              billDate: parseDt(m['bill_date']) ?? DateTime.now(),
              vehicleCategory:
                  vehicleTypeConverter.fromSql(m['vehicle_category'] as String),
              customerName: m['customer_name'] as String,
              vehicleNumberPlate: Value(m['vehicle_number_plate'] as String?),
              customerPhone: Value(m['customer_phone'] as String?),
              notes: Value(m['notes'] as String?),
              createdAt: Value(parseDt(m['created_at']) ?? DateTime.now()),
            ),
          );
    }

    final recs = tables['recommendation_queue'] as List<dynamic>? ?? [];
    for (final raw in recs) {
      final m = Map<String, dynamic>.from(raw as Map);
      final typeRaw = m['type'] as String?;
      await _db.into(_db.recommendationQueue).insertOnConflictUpdate(
            RecommendationQueueCompanion.insert(
              id: m['id'] as String,
              message: m['message'] as String,
              customerId: Value(m['customer_id'] as String?),
              vehicleNumberPlate: Value(m['vehicle_number_plate'] as String?),
              type: Value(typeRaw == null ? null : recommendationTypeConverter.fromSql(typeRaw)),
              scheduledFor: Value(parseDt(m['scheduled_for'])),
              sent: Value(m['sent'] as bool? ?? false),
            ),
          );
    }
  }
}
