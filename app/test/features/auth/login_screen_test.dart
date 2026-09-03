import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/features/auth/auth_providers.dart';
import 'package:workshop_os/features/auth/login_screen.dart';

import '../../helpers/fake_auth_gateway.dart';

void main() {
  late FakeAuthGateway gateway;

  Widget screen() => ProviderScope(
        overrides: [
          authGatewayProvider.overrideWithValue(gateway),
        ],
        child: const MaterialApp(home: LoginScreen()),
      );

  setUp(() {
    gateway = FakeAuthGateway();
  });

  Future<void> enterCredentials(WidgetTester tester) async {
    await tester.enterText(find.byKey(const Key('login_email')),
        'receptionist@workshop.test');
    await tester.enterText(
        find.byKey(const Key('login_password')), 'secret123');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
  }

  testWidgets('failed login shows error and stays on the form', (tester) async {
    gateway.signInError = Exception('invalid credentials');
    await tester.pumpWidget(screen());

    await enterCredentials(tester);

    expect(find.byKey(const Key('login_error')), findsOneWidget);
    expect(find.text('Login failed. Check email and password.'),
        findsOneWidget);
    expect(gateway.signInCalls, hasLength(1));
    expect(gateway.signedInUser, isNull);
  });

  testWidgets('successful login calls gateway with trimmed email',
      (tester) async {
    await tester.pumpWidget(screen());

    await tester.enterText(
        find.byKey(const Key('login_email')), 'owner@workshop.test ');
    await tester.enterText(
        find.byKey(const Key('login_password')), 'secret123');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_error')), findsNothing);
    expect(gateway.signInCalls.single.email, 'owner@workshop.test');
    expect(gateway.signedInUser?.email, 'owner@workshop.test');
  });
}
