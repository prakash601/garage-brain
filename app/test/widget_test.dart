import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/main.dart';

void main() {
  testWidgets('unauthenticated users land on the login screen',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: WorkshopOsApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
