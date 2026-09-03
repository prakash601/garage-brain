import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';

enum AppRole { receptionist, owner }

@immutable
class AuthUser {
  const AuthUser({required this.id, required this.email, required this.role});

  final String id;
  final String email;
  final AppRole? role;
}

AppRole? appRoleFromClaim(Object? claim) => switch (claim) {
      'receptionist' => AppRole.receptionist,
      'owner' => AppRole.owner,
      _ => null,
    };

/// Decodes the `app_role` custom claim embedded by the Supabase
/// custom-access-token hook (DESIGN.md §8).
AppRole? roleFromAccessToken(String accessToken) {
  final parts = accessToken.split('.');
  if (parts.length < 2) return null;
  try {
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    ) as Map<String, dynamic>;
    return appRoleFromClaim(payload['app_role']);
  } on FormatException {
    return null;
  }
}

/// Local-development fallback used when SUPABASE_URL/ANON_KEY are absent:
/// signs in as a fake owner so the full app is usable without a backend
/// (no data ever leaves the device; Drift still works offline-first).
class DevAuthGateway implements AuthGateway {
  final _controller = StreamController<AuthUser?>.broadcast();

  AuthUser? _user;

  static const _devUser = AuthUser(
    id: 'dev-user',
    email: 'dev@workshop.test',
    role: AppRole.owner,
  );

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _user = email.trim().isEmpty ? _devUser : AuthUser(
      id: _devUser.id,
      email: email.trim(),
      role: AppRole.owner,
    );
    _controller.add(_user);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  @override
  Stream<AuthUser?> get onAuthChanged => _controller.stream;
}

abstract class AuthGateway {
  AuthUser? get currentUser;

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Stream<AuthUser?> get onAuthChanged;
}

class SupabaseAuthGateway implements AuthGateway {
  bool get _configured => AppConfig.isSupabaseConfigured;

  GoTrueClient get _auth {
    if (!_configured) {
      throw StateError('Supabase is not configured (SUPABASE_URL/ANON_KEY)');
    }
    return Supabase.instance.client.auth;
  }

  AuthUser? _userFromSession(Session? session) {
    if (session == null) return null;
    return AuthUser(
      id: session.user.id,
      email: session.user.email ?? '',
      role: roleFromAccessToken(session.accessToken),
    );
  }

  @override
  AuthUser? get currentUser =>
      _configured ? _userFromSession(_auth.currentSession) : null;

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => _configured ? _auth.signOut() : Future.value();

  @override
  Stream<AuthUser?> get onAuthChanged {
    if (!_configured) return Stream.value(null);
    return _auth.onAuthStateChange
        .map((event) => _userFromSession(event.session));
  }
}
