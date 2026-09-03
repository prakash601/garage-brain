import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/sync_banner.dart';
import '../features/auth/auth_gateway.dart';
import '../features/auth/auth_providers.dart';
import '../features/auth/login_screen.dart';
import '../features/backup/backup_screen.dart';
import '../features/create_job/create_job_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/job_detail/job_detail_screen.dart';
import '../features/old_bills/old_bills_screen.dart';
import '../features/search/search_screen.dart';

final class RoutePaths {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const search = '/search';
  static const newJob = '/new-job';
  static const job = '/job';
  static const oldBills = '/old-bills';
  static const admin = '/admin';
}

/// Pure redirect policy (DESIGN.md §2 role table): unauthenticated → login;
/// signed-in on login → dashboard; admin routes owner-only.
String? routeRedirect({
  required String location,
  required bool signedIn,
  required AppRole? role,
}) {
  final onLogin = location == RoutePaths.login;
  if (!signedIn) return onLogin ? null : RoutePaths.login;
  if (onLogin) return RoutePaths.dashboard;
  if (location.startsWith(RoutePaths.admin) && role != AppRole.owner) {
    return RoutePaths.dashboard;
  }
  return null;
}

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Stream<AuthUser?> changes) {
    changes.listen((_) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final gateway = ref.watch(authGatewayProvider);
  final listenable = _AuthListenable(gateway.onAuthChanged);
  ref.onDispose(listenable.dispose);

  return GoRouter(
    initialLocation: RoutePaths.login,
    refreshListenable: listenable,
    redirect: (_, state) => routeRedirect(
      location: state.matchedLocation,
      signedIn: gateway.currentUser != null,
      role: gateway.currentUser?.role,
    ),
    routes: [
      GoRoute(path: RoutePaths.login, builder: (_, _) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => _HomeShell(shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.dashboard,
              builder: (_, _) => const DashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.search,
              builder: (_, _) => const SearchScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.newJob,
              builder: (_, _) => const CreateJobScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.oldBills,
              builder: (_, _) => const OldBillsScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '${RoutePaths.job}/:id',
        builder: (_, state) => JobDetailScreen(jobId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.admin,
        builder: (_, _) => const BackupScreen(),
      ),
    ],
  );
});

final class AdminStubScreen extends StatelessWidget {
  const AdminStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: const Center(
        child: Text(
          'Admin area\n(user management lives in the Supabase dashboard for now)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _HomeShell extends StatelessWidget {
  const _HomeShell(this.shell);

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SyncBanner(),
          Expanded(child: shell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Jobs',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'New Job',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_edu_outlined),
            selectedIcon: Icon(Icons.history_edu),
            label: 'Import',
          ),
        ],
      ),
    );
  }
}
