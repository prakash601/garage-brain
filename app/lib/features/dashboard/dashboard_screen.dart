import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/status_colors.dart';
import '../../core/utils/job_number.dart';
import '../../core/widgets/content_frame.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/drift/enums.dart';
import '../auth/auth_gateway.dart';
import '../auth/auth_providers.dart';
import '../../routing/app_router.dart';
import 'dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(todayJobsProvider);
    final offline = ref.watch(offlineProvider).value ?? false;
    final user = ref.watch(authUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          if (offline)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Chip(
                key: Key('offline_badge'),
                avatar: Icon(Icons.cloud_off, size: 16),
                label: Text('Offline'),
              ),
            ),
          if (user?.role == AppRole.owner)
            IconButton(
              key: const Key('admin_entry'),
              tooltip: 'Admin',
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () => context.push(RoutePaths.admin),
            ),
        ],
      ),
      body: jobs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (list) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(todayJobsProvider),
          child: _DashboardBody(jobs: list),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('dashboard_new_job_fab'),
        onPressed: () =>
            GoRouter.maybeOf(context)?.push(RoutePaths.newJob),
        icon: const Icon(Icons.add),
        label: const Text('New Job'),
      ),
    );
  }
}

enum DashboardFilter { all, pending, ready, delivered }

class _DashboardBody extends ConsumerStatefulWidget {
  const _DashboardBody({required this.jobs});

  final List<DashboardJob> jobs;

  @override
  ConsumerState<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends ConsumerState<_DashboardBody> {
  DashboardFilter _filter = DashboardFilter.all;

  @override
  Widget build(BuildContext context) {
    final active = widget.jobs.where((j) => !j.closed).toList(growable: false);
    final pending = active.where((j) => j.isPending).length;
    final completed = active.where((j) => j.isCompleted).length;
    final visible = switch (_filter) {
      DashboardFilter.all => active,
      DashboardFilter.pending => active.where((j) => j.isPending).toList(),
      DashboardFilter.ready => active
          .where((j) => j.status == JobStatus.readyForDelivery)
          .toList(),
      DashboardFilter.delivered => active
          .where((j) => j.status == JobStatus.delivered)
          .toList(),
    };

    return ContentFrame(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _CountCard(
                  key: Key('pending_count'),
                  label: 'Pending',
                  value: pending,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                _CountCard(
                  key: Key('completed_count'),
                  label: 'Completed',
                  value: completed,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ],
            ),
          ),
        Expanded(
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    for (final f in DashboardFilter.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          key: Key('filter_${f.name}'),
                          label: Text(switch (f) {
                            DashboardFilter.all => 'All (${active.length})',
                            DashboardFilter.pending => 'Pending ($pending)',
                            DashboardFilter.ready => 'Ready',
                            DashboardFilter.delivered =>
                              'Delivered ($completed)',
                          }),
                          selected: _filter == f,
                          onSelected: (_) =>
                              setState(() => _filter = f),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: visible.isEmpty
                    ? EmptyState(
                        icon: active.isEmpty
                            ? Icons.receipt_long_outlined
                            : Icons.filter_list_off_outlined,
                        title: active.isEmpty
                            ? 'No open jobs today'
                            : 'No jobs match this filter',
                        subtitle: active.isEmpty
                            ? 'New jobs appear here as they are created.'
                            : null,
                        actionLabel:
                            active.isEmpty ? 'New Job' : null,
                        onAction: active.isEmpty
                            ? () => GoRouter.maybeOf(context)
                                ?.push(RoutePaths.newJob)
                            : null,
                      )
                    : ListView.separated(
                        itemCount: visible.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) =>
                            _JobTile(job: visible[index]),
                      ),
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }
}

class _JobTile extends ConsumerStatefulWidget {
  const _JobTile({required this.job});

  final DashboardJob job;

  @override
  ConsumerState<_JobTile> createState() => _JobTileState();
}

class _JobTileState extends ConsumerState<_JobTile> {
  bool _closing = false;

  Future<void> _confirmClose() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close job?'),
        content: Text(
            '${formatJobNumber(widget.job.jobNo)} (${widget.job.plate}) will be '
            'removed from the active list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_close_job'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _closing = true);
    try {
      await ref
          .read(jobRepositoryProvider)
          .closeJob(widget.job.jobId);
    } finally {
      if (mounted) setState(() => _closing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return ListTile(
      key: Key('job_tile_${job.jobNo}'),
      onTap: () =>
          GoRouter.maybeOf(context)?.push('${RoutePaths.job}/${job.jobId}'),
      leading: _StatusChip(status: job.status),
      title: Text('${formatJobNumber(job.jobNo)} · ${job.plate}'),
      subtitle: Text(
          '${job.customerName} · ${vehicleTypeLabel(job.vehicleType)}'),
      trailing: (job.isCompleted && !_closing)
          ? IconButton(
              key: Key('close_job_${job.jobNo}'),
              tooltip: 'Close job',
              icon: const Icon(Icons.check_circle_outline),
              onPressed: _confirmClose,
            )
          : _closing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : null,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    final style = jobStatusChipStyle(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(style.label,
          style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text('$value',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: color)),
              Text(label, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}
