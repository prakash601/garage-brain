import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/features/auth/auth_gateway.dart';
import 'package:workshop_os/routing/app_router.dart';

void main() {
  group('routeRedirect', () {
    test('unauthenticated user is sent to login from anywhere else', () {
      expect(
        routeRedirect(
          location: RoutePaths.dashboard,
          signedIn: false,
          role: null,
        ),
        RoutePaths.login,
      );
      expect(
        routeRedirect(
          location: RoutePaths.search,
          signedIn: false,
          role: null,
        ),
        RoutePaths.login,
      );
    });

    test('unauthenticated user can stay on login', () {
      expect(
        routeRedirect(location: RoutePaths.login, signedIn: false, role: null),
        isNull,
      );
    });

    test('signed-in user never sees login', () {
      expect(
        routeRedirect(
          location: RoutePaths.login,
          signedIn: true,
          role: AppRole.receptionist,
        ),
        RoutePaths.dashboard,
      );
    });

    test('signed-in receptionist reaches staff routes', () {
      for (final location in [
        RoutePaths.dashboard,
        RoutePaths.search,
        RoutePaths.newJob,
        '${RoutePaths.job}/abc',
      ]) {
        expect(
          routeRedirect(
            location: location,
            signedIn: true,
            role: AppRole.receptionist,
          ),
          isNull,
        );
      }
    });

    test('admin entry point is owner-only', () {
      expect(
        routeRedirect(
          location: RoutePaths.admin,
          signedIn: true,
          role: AppRole.owner,
        ),
        isNull,
      );
      expect(
        routeRedirect(
          location: RoutePaths.admin,
          signedIn: true,
          role: AppRole.receptionist,
        ),
        RoutePaths.dashboard,
      );
      expect(
        routeRedirect(
          location: RoutePaths.admin,
          signedIn: true,
          role: null,
        ),
        RoutePaths.dashboard,
      );
    });
  });

  group('roleFromAccessToken', () {
    String fakeJwt(Map<String, Object?> payload) {
      final encoded = base64Url.encode(utf8.encode(jsonEncode(payload)));
      return 'header.$encoded.signature';
    }

    test('reads app_role claim', () {
      expect(
        roleFromAccessToken(fakeJwt({'app_role': 'owner'})),
        AppRole.owner,
      );
      expect(
        roleFromAccessToken(fakeJwt({'app_role': 'receptionist'})),
        AppRole.receptionist,
      );
    });

    test('unknown or missing claim yields null', () {
      expect(roleFromAccessToken(fakeJwt({})), isNull);
      expect(roleFromAccessToken(fakeJwt({'app_role': 'superuser'})), isNull);
      expect(roleFromAccessToken('garbage'), isNull);
    });
  });
}
