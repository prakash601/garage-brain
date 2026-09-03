import '../../core/utils/phone.dart';

/// Prefilled "ready for delivery" WhatsApp deep link (DESIGN.md §9):
/// vehicle label + job number + ready text via wa.me.
String buildWhatsAppReadyUrl({
  required String phone,
  required String jobNo,
  required String vehicleLabel,
}) {
  var digits = normalizePhone(phone);
  if (!digits.startsWith('91') && digits.length == 10) {
    digits = '91$digits';
  }
  final message =
      'Namaste! Your vehicle $vehicleLabel (Job $jobNo) is ready for '
      'delivery. Kindly collect at your convenience.';
  return 'https://wa.me/$digits?text=${Uri.encodeComponent(message)}';
}
