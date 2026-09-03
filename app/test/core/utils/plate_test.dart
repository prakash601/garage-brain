import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/core/utils/plate.dart';

void main() {
  group('normalizePlate', () {
    test('uppercases lowercase input', () {
      expect(normalizePlate('mh12ab1234'), 'MH12AB1234');
    });

    test('strips spaces', () {
      expect(normalizePlate('MH 12 AB 1234'), 'MH12AB1234');
    });

    test('strips hyphens', () {
      expect(normalizePlate('MH-12-AB-1234'), 'MH12AB1234');
    });

    test('handles mixed case with mixed separators', () {
      expect(normalizePlate('ka-05 Mj 2509'), 'KA05MJ2509');
    });

    test('leaves digits untouched', () {
      expect(normalizePlate('123456'), '123456');
    });

    test('empty string stays empty', () {
      expect(normalizePlate(''), '');
    });
  });

  group('classifyPlate', () {
    group('green — classic Indian pattern', () {
      test('standard car plate, 4-digit series', () {
        expect(classifyPlate('MH12AB1234'), PlateFlag.green);
      });

      test('single-letter series, short number', () {
        expect(classifyPlate('DL03CAF1'), PlateFlag.green);
      });

      test('three-letter series (BH-era style)', () {
        expect(classifyPlate('KA05MJC2024'), PlateFlag.green);
      });

      test('lowercase input classified after normalization', () {
        expect(classifyPlate('mh12ab1234'), PlateFlag.green);
      });

      test('letter O allowed in alpha positions', () {
        expect(classifyPlate('MH12AO1234'), PlateFlag.green);
      });
    });

    group('amber — non-classic alnum, 6–11 chars', () {
      test('BH-series format', () {
        expect(classifyPlate('21BH2345A'), PlateFlag.amber);
      });

      test('all digits, 6 chars', () {
        expect(classifyPlate('123456'), PlateFlag.amber);
      });

      test('11-char alnum boundary', () {
        expect(classifyPlate('AB123456789'), PlateFlag.amber);
      });

      test('classic shape but bad digit placement', () {
        expect(classifyPlate('MHI2AB1234'), PlateFlag.amber);
      });

      test('zero where O expected still alnum amber', () {
        expect(classifyPlate('0123AB'), PlateFlag.amber);
      });
    });

    group('red — invalid', () {
      test('invalid characters rejected', () {
        expect(classifyPlate('MH12@B1234'), PlateFlag.red);
      });

      test('too short (5 chars)', () {
        expect(classifyPlate('ABCDE'), PlateFlag.red);
      });

      test('too long (12 chars)', () {
        expect(classifyPlate('AB1234567890'), PlateFlag.red);
      });

      test('empty string', () {
        expect(classifyPlate('   '), PlateFlag.red);
      });

      test('only separators', () {
        expect(classifyPlate('-- -- --'), PlateFlag.red);
      });
    });
  });
}
