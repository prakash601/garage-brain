import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/core/utils/validators.dart';

void main() {
  group('isValidCustomerName', () {
    test('accepts 2+ chars', () {
      expect(isValidCustomerName('Ab'), isTrue);
      expect(isValidCustomerName('  Ramesh Kumar  '), isTrue);
    });

    test('rejects blank and single chars', () {
      expect(isValidCustomerName(null), isFalse);
      expect(isValidCustomerName(''), isFalse);
      expect(isValidCustomerName('  '), isFalse);
      expect(isValidCustomerName('A'), isFalse);
    });
  });

  group('tryParseKm', () {
    test('empty means absent', () {
      expect(tryParseKm(null), isNull);
      expect(tryParseKm(''), isNull);
      expect(tryParseKm('   '), isNull);
    });

    test('parses non-negative readings', () {
      expect(tryParseKm('0'), 0);
      expect(tryParseKm(' 12456 '), 12456);
    });

    test('rejects garbage and negatives', () {
      expect(tryParseKm('abc'), isNull);
      expect(tryParseKm('-50'), isNull);
      expect(tryParseKm('12.5'), isNull);
    });
  });
}
