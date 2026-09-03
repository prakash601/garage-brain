import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/drift/database_provider.dart';
import 'search_service.dart';

/// Raw text typed by the user (screen state lives in its TextEditingController;
/// only the debounced value lands here).
final debouncedSearchQueryProvider =
    NotifierProvider<DebouncedSearchQueryNotifier, String>(
  DebouncedSearchQueryNotifier.new,
);

class DebouncedSearchQueryNotifier extends Notifier<String> {
  Timer? _timer;

  @override
  String build() {
    ref.onDispose(() => _timer?.cancel());
    return '';
  }

  void submit(String raw) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 250), () {
      state = raw;
    });
  }
}

final searchServiceProvider = Provider<SearchService>(
  (ref) => SearchService(ref.watch(appDatabaseProvider)),
);

final searchResultsProvider = FutureProvider.autoDispose<List<TimelineHit>>(
  (ref) async {
    final query = ref.watch(debouncedSearchQueryProvider);
    final hits = await ref.watch(searchServiceProvider).search(query);
    if (query.trim().isNotEmpty && hits.isNotEmpty) {
      ref.read(recentSearchesProvider.notifier).push(query.trim());
    }
    return hits;
  },
);

class RecentSearchesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => const [];

  void push(String query) {
    if (query.isEmpty || state.contains(query)) return;
    state = [query, ...state].take(8).toList(growable: false);
  }

  void clear() => state = const [];
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesNotifier, List<String>>(
  RecentSearchesNotifier.new,
);
