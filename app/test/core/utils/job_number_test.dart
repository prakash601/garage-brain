import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/core/utils/job_number.dart';

void main() {
  test('formats 1 as JOB-000001', () {
    expect(formatJobNumber(1), 'JOB-000001');
  });

  test('formats multi-digit numbers padded to 6', () {
    expect(formatJobNumber(42), 'JOB-000042');
  });

  test('formats exactly 6 digits unchanged', () {
    expect(formatJobNumber(999999), 'JOB-999999');
  });

  test('does not truncate numbers beyond 6 digits', () {
    expect(formatJobNumber(1234567), 'JOB-1234567');
  });
}
