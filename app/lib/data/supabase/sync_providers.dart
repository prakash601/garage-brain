import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../drift/app_database.dart';
import '../drift/database_provider.dart';
import 'remote_gateway.dart';
import 'supabase_remote_gateway.dart';
import 'sync_worker.dart';

class _NoopRemoteGateway implements RemoteGateway {
  @override
  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {}

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    String column,
    String? since,
  ) async =>
      const [];
}

final remoteGatewayProvider = Provider<RemoteGateway>((ref) {
  if (AppConfig.isSupabaseConfigured) {
    return SupabaseRemoteGateway(Supabase.instance.client);
  }
  return _NoopRemoteGateway();
});

final syncWorkerProvider = Provider<SyncWorker>((ref) {
  final worker = SyncWorker(
    ref.watch(appDatabaseProvider),
    ref.watch(remoteGatewayProvider),
    connectivity: Connectivity(),
  );
  ref.onDispose(() => worker.stop());
  return worker;
});

class SyncStatus {
  const SyncStatus({this.syncing = false, this.lastSyncAt, this.lastError});

  final bool syncing;
  final DateTime? lastSyncAt;
  final String? lastError;
}

class SyncStatusNotifier extends Notifier<SyncStatus> {
  @override
  SyncStatus build() => const SyncStatus();

  Future<void> syncNow() async {
    if (state.syncing) return;
    state = const SyncStatus(syncing: true);
    try {
      final worker = ref.read(syncWorkerProvider);
      await worker.syncNow();
      state = SyncStatus(
        lastSyncAt: worker.lastSyncAt ?? state.lastSyncAt,
        lastError: worker.lastError,
      );
    } catch (e) {
      state = SyncStatus(lastError: '$e', lastSyncAt: state.lastSyncAt);
    } finally {
      ref.invalidate(pendingCountProvider);
    }
  }
}

final syncStatusProvider =
    NotifierProvider<SyncStatusNotifier, SyncStatus>(SyncStatusNotifier.new);

Future<int> _unsyncedCount(AppDatabase db) async {
  var total = 0;
  total += await (db.selectOnly(db.customers)
        ..addColumns([db.customers.id.count()])
        ..where(db.customers.synced.equals(false)))
      .map((r) => r.read(db.customers.id.count()) ?? 0)
      .getSingle();
  total += await (db.selectOnly(db.vehicles)
        ..addColumns([db.vehicles.numberPlate.count()])
        ..where(db.vehicles.synced.equals(false)))
      .map((r) => r.read(db.vehicles.numberPlate.count()) ?? 0)
      .getSingle();
  total += await (db.selectOnly(db.jobCards)
        ..addColumns([db.jobCards.id.count()])
        ..where(db.jobCards.synced.equals(false)))
      .map((r) => r.read(db.jobCards.id.count()) ?? 0)
      .getSingle();
  total += await (db.selectOnly(db.oldBills)
        ..addColumns([db.oldBills.id.count()])
        ..where(db.oldBills.synced.equals(false)))
      .map((r) => r.read(db.oldBills.id.count()) ?? 0)
      .getSingle();
  total += await (db.selectOnly(db.carOwnershipHistory)
        ..addColumns([db.carOwnershipHistory.id.count()])
        ..where(db.carOwnershipHistory.synced.equals(false)))
      .map((r) => r.read(db.carOwnershipHistory.id.count()) ?? 0)
      .getSingle();
  return total;
}

final pendingCountProvider = StreamProvider<int>((ref) async* {
  final db = ref.watch(appDatabaseProvider);
  yield await _unsyncedCount(db);
  await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
    yield await _unsyncedCount(db);
  }
});
