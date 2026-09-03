import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/status_colors.dart';
import '../../core/utils/phone.dart';
import '../../core/utils/plate.dart';
import '../../core/widgets/content_frame.dart';
import '../../core/widgets/empty_state.dart';
import '../../routing/app_router.dart';
import 'search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final recents = ref.watch(recentSearchesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ContentFrame(
        child: Column(
          children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              key: const Key('search_field'),
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Plate, phone, or name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _plateFlag(),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
                ref.read(debouncedSearchQueryProvider.notifier).submit(value);
              },
            ),
          ),
          if (_controller.text.trim().isEmpty && recents.isNotEmpty)
            _RecentChips(
              recents: recents,
              onPick: (q) {
                _controller.text = q;
                setState(() {});
                ref.read(debouncedSearchQueryProvider.notifier).submit(q);
              },
              onClear: () =>
                  ref.read(recentSearchesProvider.notifier).clear(),
            ),
          Expanded(
            child: results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (hits) {
                if (_controller.text.trim().isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_outlined,
                    title: 'Search by plate, phone, or name',
                    subtitle:
                        'Recent jobs and imported bills appear here.',
                  );
                }
                if (hits.isEmpty) {
                  return _NotFoundCta(query: _controller.text);
                }
                final jobs = hits.where((h) => h.isJob).length;
                final bills = hits.length - jobs;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${hits.length} result${hits.length == 1 ? '' : 's'}'
                          ' · $jobs jobs · $bills bills',
                          key: const Key('search_result_count'),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: hits.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final hit = hits[index];
                          return ListTile(
                            key: Key('hit_$index'),
                            leading: Icon(
                              hit.isOldBill
                                  ? Icons.history
                                  : Icons.receipt_long,
                            ),
                            title: Text(hit.headline),
                            subtitle: Text(hit.subline),
                            trailing:
                                Text(_dateLabel(context, hit.date)),
                            onTap: hit.jobId == null
                                ? null
                                : () => context.push(
                                    '${RoutePaths.job}/${hit.jobId}'),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget? _plateFlag() {
    final text = _controller.text;
    if (text.isEmpty) return null;
    if (normalizePhone(text).length >= 4 &&
        RegExp(r'^[0-9+\- ]+$').hasMatch(text)) {
      return null; // phone-like input gets no plate flag
    }
    final flag = classifyPlate(text);
    return Icon(
      Icons.circle,
      size: 14,
      key: Key('plate_flag_${flag.name}'),
      color: plateFlagColor(context, flag),
    );
  }
}

String _dateLabel(BuildContext context, DateTime date) {
  final local = date.toLocal();
  return '${local.day}/${local.month}/${local.year}';
}

class _RecentChips extends StatelessWidget {
  const _RecentChips({
    required this.recents,
    required this.onPick,
    required this.onClear,
  });

  final List<String> recents;
  final ValueChanged<String> onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Recent', style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              TextButton(
                key: const Key('clear_recents'),
                onPressed: onClear,
                child: const Text('Clear'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final q in recents)
                ActionChip(
                  key: Key('recent_$q'),
                  label: Text(q),
                  onPressed: () => onPick(q),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _NotFoundCta extends StatelessWidget {
  const _NotFoundCta({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,
                size: 48,
                color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text('No matching history found',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('“$query” isn’t in local records yet.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('search_create_job_cta'),
              onPressed: () => context.push(RoutePaths.newJob),
              icon: const Icon(Icons.add),
              label: const Text('Create Job'),
            ),
          ],
        ),
      ),
    );
  }
}
