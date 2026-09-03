import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/supabase/sync_providers.dart';
import '../../features/dashboard/dashboard_providers.dart';

class SyncBanner extends ConsumerWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(offlineProvider).value ?? false;
    final pending = ref.watch(pendingCountProvider).value ?? 0;
    final status = ref.watch(syncStatusProvider);
    final syncing = status.syncing;

    if (!offline && pending == 0 && status.lastError == null) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final (icon, label, color) = offline
        ? (
            Icons.cloud_off_outlined,
            pending > 0
                ? 'Offline · $pending change${pending == 1 ? '' : 's'} queued'
                : 'Offline · changes will queue',
            scheme.errorContainer,
          )
        : status.lastError != null
            ? (
                Icons.sync_problem_outlined,
                'Sync failed — tap to retry',
                scheme.errorContainer,
              )
            : (
                Icons.cloud_upload_outlined,
                '$pending change${pending == 1 ? '' : 's'} waiting to sync',
                scheme.secondaryContainer,
              );

    return Material(
      color: color,
      child: InkWell(
        onTap: syncing
            ? null
            : () => ref.read(syncStatusProvider.notifier).syncNow(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    key: const Key('sync_banner_label'),
                    style: Theme.of(context).textTheme.labelLarge),
              ),
              if (syncing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.refresh, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
