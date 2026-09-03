import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/core/utils/phone.dart';

void main() {
  group('normalizePhone', () {
    test('already-normalized 10-digit number is unchanged', () {
      expect(normalizePhone('9876543210'), '9876543210');
    });

    test('strips spaces', () {
      expect(normalizePhone('98765 43210'), '9876543210');
    });

    test('strips dashes', () {
      expect(normalizePhone('98765-43210'), '9876543210');
    });

    test('strips +91 prefix with plus and space', () {
      expect(normalizePhone('+91 98765 43210'), '9876543210');
    });

    test('strips 91 prefix without plus', () {
      expect(normalizePhone('919876543210'), '9876543210');
    });

    test('strips mixed separators around 91 prefix', () {
      expect(normalizePhone('+91-98765-43210'), '9876543210');
    });

    test('does not strip 91 from a valid 10-digit number starting 91', () {
      expect(normalizePhone('9198765432'), '9198765432');
    });

    test('strips trunk-prefix 0', () {
      expect(normalizePhone('09876543210'), '9876543210');
    });

    test('strips brackets, dots, and slashes', () {
      expect(normalizePhone('(98765) 43210'), '9876543210');
      expect(normalizePhone('98765.43210'), '9876543210');
      expect(normalizePhone('98765/43210'), '9876543210');
    });

    test('empty string stays empty', () {
      expect(normalizePhone(''), '');
    });

    test('letters are preserved (validation rejects them)', () {
      expect(normalizePhone('98abc43210'), '98abc43210');
    });
  });

  group('isValidPhone', () {
    test('accepts numbers starting 6-9', () {
      for (final first in ['6', '7', '8', '9']) {
        expect(isValidPhone('${first}123456789'), isTrue, reason: first);
      }
    });

    test('rejects numbers starting 0-5', () {
      for (var i = 0; i <= 5; i++) {
        expect(isValidPhone('${i}123456789'), isFalse, reason: '$i');
      }
    });

    test('rejects too short (9 digits)', () {
      expect(isValidPhone('987654321'), isFalse);
    });

    test('rejects too long (11 digits)', () {
      expect(isValidPhone('98765432101'), isFalse);
    });

    test('rejects empty string', () {
      expect(isValidPhone(''), isFalse);
    });

    test('rejects letters', () {
      expect(isValidPhone('98765O43210'.substring(0, 10)), isFalse);
    });

    test('rejects letter O in place of zero', () {
      expect(isValidPhone('98765O4321'), isFalse);
    });
  });

  group('isValidRawPhone', () {
    test('formatted input with +91 validates', () {
      expect(isValidRawPhone('+91 88765 43210'), isTrue);
    });

    test('dashed input validates', () {
      expect(isValidRawPhone('78765-43210'), isTrue);
    });

    test('garbage does not validate', () {
      expect(isValidRawPhone('not a phone'), isFalse);
    });
  });
}
