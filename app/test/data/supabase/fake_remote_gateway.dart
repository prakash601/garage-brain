import 'package:workshop_os/data/supabase/remote_gateway.dart';

/// Shared in-memory stand-in for Supabase. One instance plays the role of
/// the hosted backend; each simulated device gets its own Drift database
/// plus its own [SyncWorker] pointed at the same gateway.
class FakeRemoteGateway implements RemoteGateway {
  final Map<String, List<Map<String, dynamic>>> store = {};
  final List<({String table, List<Map<String, dynamic>> rows})> upserts = [];

  @override
  Future<void> upsert(
      String table, List<Map<String, dynamic>> rows) async {
    upserts.add((table: table, rows: rows));
    final bucket = store.putIfAbsent(table, () => []);
    for (final row in rows) {
      final pk = table == 'vehicles' ? 'number_plate' : 'id';
      bucket.removeWhere((r) => r[pk] == row[pk]);
      bucket.add(row);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    String column,
    String? since,
  ) async {
    final bucket = store[table] ?? const [];
    return bucket
        .where((r) => since == null || (r[column] as String).compareTo(since) > 0)
        .toList();
  }
}
