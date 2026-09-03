enum PlateFlag { green, amber, red }

final RegExp _alnumRegex = RegExp(r'^[A-Z0-9]+$');
final RegExp _classicRegex = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{1,3}[0-9]{1,4}$');

String normalizePlate(String raw) =>
    raw.toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');

PlateFlag classifyPlate(String plate) {
  final normalized = normalizePlate(plate);
  if (!_alnumRegex.hasMatch(normalized)) return PlateFlag.red;
  if (_classicRegex.hasMatch(normalized)) return PlateFlag.green;
  if (normalized.length >= 6 && normalized.length <= 11) {
    return PlateFlag.amber;
  }
  return PlateFlag.red;
}
