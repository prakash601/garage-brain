import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import 'auth_gateway.dart';

final authGatewayProvider = Provider<AuthGateway>((ref) {
  if (AppConfig.isSupabaseConfigured) return SupabaseAuthGateway();
  return DevAuthGateway();
});

final authUserProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authGatewayProvider).onAuthChanged,
);
