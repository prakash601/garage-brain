/// Transport-agnostic contract for the sync worker. Tests supply a fake;
/// production uses [SupabaseRemoteGateway].
abstract class RemoteGateway {
  /// Upserts rows keyed by their client-generated primary key.
  Future<void> upsert(String table, List<Map<String, dynamic>> rows);

  /// Returns all remote rows whose [column] (a timestamp) is newer than
  /// [since] (ISO-8601 string), or everything when [since] is null.
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    String column,
    String? since,
  );
}
