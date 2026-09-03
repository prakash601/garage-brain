import 'package:supabase_flutter/supabase_flutter.dart';

import 'remote_gateway.dart';

class SupabaseRemoteGateway implements RemoteGateway {
  SupabaseRemoteGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return;
    await _client.from(table).upsert(rows);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    String column,
    String? since,
  ) async {
    var query = _client.from(table).select();
    if (since != null) {
      query = query.gt(column, since);
    }
    final result = await query;
    return List<Map<String, dynamic>>.from(result as List);
  }
}
