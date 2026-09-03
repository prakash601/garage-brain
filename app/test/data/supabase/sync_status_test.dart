import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/data/drift/app_database.dart';
import 'package:workshop_os/data/supabase/remote_gateway.dart';
import 'package:workshop_os/data/supabase/sync_worker.dart';

class _ThrowingGateway implements RemoteGateway {
  @override
  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {
    throw Exception('push boom');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    String column,
    String? since,
  ) async {
    throw Exception('pull boom');
  }
}

class _EmptyGateway implements RemoteGateway {
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

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('sync failure is captured in lastError instead of throwing', () async {
    final worker = SyncWorker(db, _ThrowingGateway());
    await worker.syncNow();
    expect(worker.lastError, isNotNull);
    expect(worker.lastSyncAt, isNull);
    await worker.stop();
  });

  test('successful sync sets lastSyncAt and clears lastError', () async {
    final worker = SyncWorker(db, _EmptyGateway());
    await worker.syncNow();
    expect(worker.lastError, isNull);
    expect(worker.lastSyncAt, isNotNull);
    await worker.stop();
  });
}
