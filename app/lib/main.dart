import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'data/backup/backup_providers.dart';
import 'data/drift/app_database.dart';
import 'data/seed/demo_seed.dart';
import 'data/supabase/sync_providers.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.isSupabaseConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  } else {
    await _seedDemoDataIfEmpty();
  }

  runApp(const ProviderScope(child: WorkshopOsApp()));
}

/// Dev-mode convenience: no backend configured means local-only runs
/// (Chrome/Android), so populate an empty database with demo records once.
Future<void> _seedDemoDataIfEmpty() async {
  final db = AppDatabase();
  try {
    final hasCustomers = await db.select(db.customers).get().then((r) => r.isNotEmpty);
    if (!hasCustomers) {
      await DemoSeed.seed(db);
    }
  } finally {
    await db.close();
  }
}

class WorkshopOsApp extends ConsumerStatefulWidget {
  const WorkshopOsApp({super.key});

  @override
  ConsumerState<WorkshopOsApp> createState() => _WorkshopOsAppState();
}

class _WorkshopOsAppState extends ConsumerState<WorkshopOsApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(backupSchedulerProvider).start();
      try {
        await ref.read(syncWorkerProvider).start();
        await ref.read(syncStatusProvider.notifier).syncNow();
      } catch (_) {}
      ref.invalidate(pendingCountProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Workshop OS',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
