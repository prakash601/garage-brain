final RegExp _stripRegex = RegExp(r'[\s\-+()./]');
final RegExp _validPhoneRegex = RegExp(r'^[6-9][0-9]{9}$');

String normalizePhone(String raw) {
  var cleaned = raw.replaceAll(_stripRegex, '');
  // Trunk prefix: receptionists often type a leading 0 (09876543210).
  if (cleaned.length > 10 && cleaned.startsWith('0')) {
    cleaned = cleaned.substring(1);
  }
  if (cleaned.length == 12 && cleaned.startsWith('91')) {
    cleaned = cleaned.substring(2);
  }
  return cleaned;
}

bool isValidPhone(String phone) => _validPhoneRegex.hasMatch(phone);

bool isValidRawPhone(String raw) => isValidPhone(normalizePhone(raw));
