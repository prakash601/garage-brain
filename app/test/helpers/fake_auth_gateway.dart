import 'dart:async';

import 'package:workshop_os/features/auth/auth_gateway.dart';

class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({this.signedInUser});

  AuthUser? signedInUser;
  Object? signInError;
  final List<({String email, String password})> signInCalls = [];

  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  @override
  AuthUser? get currentUser => signedInUser;

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls.add((email: email, password: password));
    if (signInError != null) throw signInError!;
    signedInUser = AuthUser(
      id: 'user-1',
      email: email,
      role: AppRole.receptionist,
    );
    _controller.add(signedInUser);
  }

  @override
  Future<void> signOut() async {
    signedInUser = null;
    _controller.add(null);
  }

  void setRole(AppRole role) {
    signedInUser = AuthUser(
      id: 'user-1',
      email: signedInUser?.email ?? 'owner@workshop.test',
      role: role,
    );
    _controller.add(signedInUser);
  }

  @override
  Stream<AuthUser?> get onAuthChanged => _controller.stream;

  void dispose() => _controller.close();
}
