import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../drift/database_provider.dart';
import 'backup_service.dart';
import 'backup_scheduler.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BackupService(db);
});

final backupSchedulerProvider = Provider<BackupScheduler>((ref) {
  final service = ref.watch(backupServiceProvider);
  final scheduler = BackupScheduler(service);
  ref.onDispose(() => scheduler.stop());
  return scheduler;
});
