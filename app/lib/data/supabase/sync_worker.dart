import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';

import '../drift/app_database.dart';
import '../drift/enums.dart';
import 'remote_gateway.dart';
import 'sync_mappers.dart';

DateTime? _dt(Object? s) {
  if (s == null) return null;
  if (s is String && s.isEmpty) return null; // _iso() writes '' for null
  return DateTime.parse(s as String).toLocal();
}

/// Pushes unsynced Drift rows to Supabase (upsert by client UUID), pulls
/// changes since a per-table cursor, marks pushed rows synced. Triggers:
/// app start, connectivity regained, periodic timer. Conflict rule:
/// last-write-wins on `updated_at` (DESIGN.md §9).
class SyncWorker {
  SyncWorker(
    this._db,
    this._gateway, {
    this.interval = const Duration(seconds: 30),
    this.connectivity,
  });

  final AppDatabase _db;
  final RemoteGateway _gateway;
  final Duration interval;
  final Connectivity? connectivity;

  final Map<String, String> _cursors = {};
  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  bool _syncing = false;
  DateTime? lastSyncAt;
  String? lastError;

  bool get syncing => _syncing;

  Future<void> start() async {
    await syncNow();
    _timer = Timer.periodic(interval, (_) => unawaited(syncNow()));
    final conn = connectivity;
    if (conn != null) {
      _connSub = conn.onConnectivityChanged.listen((results) {
        if (!results.contains(ConnectivityResult.none)) {
          unawaited(syncNow());
        }
      });
    }
  }

  Future<void> stop() async {
    _timer?.cancel();
    await _connSub?.cancel();
    _timer = null;
    _connSub = null;
  }

  Future<void> syncNow() async {
    if (_syncing) return;
    _syncing = true;
    final errors = <String>[];
    Future<void> guard(String label, Future<void> Function() step) async {
      try {
        await step();
      } catch (e) {
        errors.add('$label: $e');
      }
    }

    try {
      // Resolve remote changes first so conflicts settle before the local
      // queue flushes (LWW on updated_at, DESIGN.md §9).
      // FK-safe pull order.
      await guard('pull customers', _pullCustomers);
      await guard('pull vehicles', _pullVehicles);
      await guard('pull ownership', _pullOwnership);
      await guard('pull jobs', _pullJobs);
      await guard('pull old bills', _pullOldBills);
      await guard('pull recommendations', _pullRecommendations);
      // FK-safe push order.
      await guard('push customers', _pushCustomers);
      await guard('push vehicles', _pushVehicles);
      await guard('push ownership', _pushOwnership);
      await guard('push jobs', _pushJobs);
      await guard('push old bills', _pushOldBills);
      await guard('push recommendations', _pushRecommendations);
      if (errors.isEmpty) {
        lastSyncAt = DateTime.now();
        lastError = null;
      } else {
        lastError = errors.join('\n');
      }
    } finally {
      _syncing = false;
    }
  }

  void _bump(String table, Object? ts) {
    if (ts is! DateTime) return;
    final iso = ts.toUtc().toIso8601String();
    final current = _cursors[table];
    if (current == null || iso.compareTo(current) > 0) {
      _cursors[table] = iso;
    }
  }

  bool _localWins(DateTime? localTs, bool localDirty, Object? remoteTs) {
    if (localDirty && localTs == null) return true;
    final remote = remoteTs is DateTime ? remoteTs : null;
    if (remote == null) return true;
    if (!localDirty) return false;
    return localTs != null && !remote.isAfter(localTs);
  }

  Future<void> _pushCustomers() async {
    final rows =
        await (_db.select(_db.customers)..where((c) => c.synced.equals(false)))
            .get();
    if (rows.isEmpty) return;
    await _gateway.upsert('customers', rows.map(customerToRow).toList());
    await (_db.update(_db.customers)
          ..where((c) => c.id.isIn(rows.map((r) => r.id))))
        .write(CustomersCompanion(
      synced: const Value(true),
      syncedAt: Value(DateTime.now()),
    ));
  }

  Future<void> _pushVehicles() async {
    final rows =
        await (_db.select(_db.vehicles)..where((v) => v.synced.equals(false)))
            .get();
    if (rows.isEmpty) return;
    await _gateway.upsert('vehicles', rows.map(vehicleToRow).toList());
    await (_db.update(_db.vehicles)
          ..where((v) => v.numberPlate.isIn(rows.map((r) => r.numberPlate))))
        .write(VehiclesCompanion(
      synced: const Value(true),
      syncedAt: Value(DateTime.now()),
    ));
  }

  Future<void> _pushOwnership() async {
    final rows = await (_db.select(_db.carOwnershipHistory)
          ..where((o) => o.synced.equals(false)))
        .get();
    if (rows.isEmpty) return;
    await _gateway.upsert(
        'car_ownership_history', rows.map(ownershipToRow).toList());
    await (_db.update(_db.carOwnershipHistory)
          ..where((o) => o.id.isIn(rows.map((r) => r.id))))
        .write(CarOwnershipHistoryCompanion(
      synced: const Value(true),
      syncedAt: Value(DateTime.now()),
    ));
  }

  Future<void> _pushJobs() async {
    final rows =
        await (_db.select(_db.jobCards)..where((j) => j.synced.equals(false)))
            .get();
    if (rows.isEmpty) return;
    await _gateway.upsert('job_cards', rows.map(jobCardToRow).toList());
    await (_db.update(_db.jobCards)
          ..where((j) => j.id.isIn(rows.map((r) => r.id))))
        .write(JobCardsCompanion(
      synced: const Value(true),
      syncedAt: Value(DateTime.now()),
    ));
  }

  Future<void> _pushOldBills() async {
    final rows =
        await (_db.select(_db.oldBills)..where((b) => b.synced.equals(false)))
            .get();
    if (rows.isEmpty) return;
    await _gateway.upsert('old_bills', rows.map(oldBillToRow).toList());
    await (_db.update(_db.oldBills)
          ..where((b) => b.id.isIn(rows.map((r) => r.id))))
        .write(OldBillsCompanion(
      synced: const Value(true),
      syncedAt: Value(DateTime.now()),
    ));
  }

  Future<void> _pushRecommendations() async {
    final rows = await (_db.select(_db.recommendationQueue)
          ..where((r) => r.synced.equals(false)))
        .get();
    if (rows.isEmpty) return;
    await _gateway.upsert(
        'recommendation_queue', rows.map(recommendationToRow).toList());
    await (_db.update(_db.recommendationQueue)
          ..where((r) => r.id.isIn(rows.map((x) => x.id))))
        .write(RecommendationQueueCompanion(
      synced: const Value(true),
      syncedAt: Value(DateTime.now()),
    ));
  }

  Future<void> _pullCustomers() async {
    final remote =
        await _gateway.fetchSince('customers', 'created_at', _cursors['customers']);
    for (final r in remote) {
      _bump('customers', _dt(r['created_at']));
      final id = r['id'] as String;
      final local = await (_db.select(_db.customers)
            ..where((c) => c.id.equals(id)))
          .getSingleOrNull();
      // No updated_at column here: locally-dirty rows win until pushed,
      // otherwise remote overwrites (DESIGN.md §9).
      if (local != null && !local.synced) continue;
      await _db.into(_db.customers).insertOnConflictUpdate(
            CustomersCompanion.insert(
              id: id,
              name: r['name'] as String,
              phone: r['phone'] as String,
              createdAt: Value(
                  _dt(r['created_at']) ?? DateTime.now()),
            ).copyWith(
              synced: const Value(true),
              syncedAt: Value(DateTime.now()),
            ),
          );
    }
  }

  Future<void> _pullVehicles() async {
    final remote = await _gateway.fetchSince(
        'vehicles', 'created_at', _cursors['vehicles']);
    for (final r in remote) {
      _bump('vehicles', _dt(r['created_at']));
      final plate = r['number_plate'] as String;
      final local = await (_db.select(_db.vehicles)
            ..where((v) => v.numberPlate.equals(plate)))
          .getSingleOrNull();
      if (local != null && !local.synced) continue;
      await _db.into(_db.vehicles).insertOnConflictUpdate(
            VehiclesCompanion.insert(
              numberPlate: plate,
              vehicleType:
                  vehicleTypeConverter.fromSql(r['vehicle_type'] as String),
              make: r['make'] as String,
              model: r['model'] as String,
              fuelType: Value(r['fuel_type'] == null
                  ? null
                  : fuelTypeConverter.fromSql(r['fuel_type'] as String)),
              currentCustomerId: Value(r['current_customer_id'] as String?),
              createdAt: Value(_dt(r['created_at']) ?? DateTime.now()),
            ).copyWith(
              synced: const Value(true),
              syncedAt: Value(DateTime.now()),
            ),
          );
    }
  }

  Future<void> _pullOwnership() async {
    final remote = await _gateway.fetchSince(
        'car_ownership_history', 'created_at', _cursors['car_ownership_history']);
    for (final r in remote) {
      _bump('car_ownership_history', _dt(r['created_at']));
      final id = r['id'] as String;
      final existing = await (_db.select(_db.carOwnershipHistory)
            ..where((o) => o.id.equals(id)))
          .getSingleOrNull();
      if (existing != null && !existing.synced) continue;
      await _db.into(_db.carOwnershipHistory).insertOnConflictUpdate(
            CarOwnershipHistoryCompanion.insert(
              id: id,
              vehicleNumberPlate: r['vehicle_number_plate'] as String,
              customerId: Value(r['customer_id'] as String?),
              startDate: Value(_dt(r['start_date']) ?? DateTime.now()),
              endDate: Value(_dt(r['end_date'])),
              createdAt: Value(_dt(r['created_at']) ?? DateTime.now()),
            ).copyWith(
              synced: const Value(true),
              syncedAt: Value(DateTime.now()),
            ),
          );
    }
  }

  Future<void> _pullJobs() async {
    final remote = await _gateway.fetchSince(
        'job_cards', 'updated_at', _cursors['job_cards']);
    for (final r in remote) {
      _bump('job_cards', _dt(r['updated_at']));
      final id = r['id'] as String;
      final local = await (_db.select(_db.jobCards)
            ..where((j) => j.id.equals(id)))
          .getSingleOrNull();
      if (local != null &&
          _localWins(local.updatedAt, !local.synced, _dt(r['updated_at']))) {
        continue;
      }
      await _db.into(_db.jobCards).insertOnConflictUpdate(
            JobCardsCompanion.insert(
              id: id,
              jobNo: r['job_no'] as int,
              vehicleNumberPlate: r['vehicle_number_plate'] as String,
              customerId: r['customer_id'] as String,
              complaints: r['complaints'] as String,
              status:
                  jobStatusConverter.fromSql(r['status'] as String),
              kmReading: Value(r['km_reading'] as int?),
              notes: Value(r['notes'] as String?),
              closed: Value(r['closed'] as bool? ?? false),
              createdBy: Value(r['created_by'] as String?),
              createdAt: Value(_dt(r['created_at']) ?? DateTime.now()),
              updatedAt: Value(_dt(r['updated_at']) ?? DateTime.now()),
            ).copyWith(
              synced: const Value(true),
              syncedAt: Value(DateTime.now()),
            ),
          );
    }
  }

  Future<void> _pullOldBills() async {
    final remote = await _gateway.fetchSince(
        'old_bills', 'created_at', _cursors['old_bills']);
    for (final r in remote) {
      _bump('old_bills', _dt(r['created_at']));
      final id = r['id'] as String;
      final existing = await (_db.select(_db.oldBills)
            ..where((b) => b.id.equals(id)))
          .getSingleOrNull();
      if (existing != null && !existing.synced) continue;
      await _db.into(_db.oldBills).insertOnConflictUpdate(
            OldBillsCompanion.insert(
              id: id,
              billNo: r['bill_no'] as String,
              billDate: _dt(r['bill_date']) ?? DateTime.now(),
              vehicleCategory: vehicleTypeConverter.fromSql(
                  r['vehicle_category'] as String),
              customerName: r['customer_name'] as String,
              vehicleNumberPlate:
                  Value(r['vehicle_number_plate'] as String?),
              customerPhone: Value(r['customer_phone'] as String?),
              notes: Value(r['notes'] as String?),
              createdAt: Value(_dt(r['created_at']) ?? DateTime.now()),
            ).copyWith(
              synced: const Value(true),
              syncedAt: Value(DateTime.now()),
            ),
          );
    }
  }

  Future<void> _pullRecommendations() async {
    final remote = await _gateway.fetchSince(
        'recommendation_queue', 'created_at', _cursors['recommendation_queue']);
    for (final r in remote) {
      _bump('recommendation_queue', _dt(r['created_at']));
      final id = r['id'] as String;
      final existing = await (_db.select(_db.recommendationQueue)
            ..where((x) => x.id.equals(id)))
          .getSingleOrNull();
      if (existing != null && !existing.synced) continue;
      await _db.into(_db.recommendationQueue).insertOnConflictUpdate(
            RecommendationQueueCompanion.insert(
              id: id,
              message: r['message'] as String,
              customerId: Value(r['customer_id'] as String?),
              vehicleNumberPlate:
                  Value(r['vehicle_number_plate'] as String?),
              type: Value(r['type'] == null
                  ? null
                  : recommendationTypeConverter.fromSql(r['type'] as String)),
              scheduledFor: Value(_dt(r['scheduled_for'])),
              sent: Value(r['sent'] as bool? ?? false),
            ).copyWith(
              synced: const Value(true),
              syncedAt: Value(DateTime.now()),
            ),
          );
    }
  }
}
