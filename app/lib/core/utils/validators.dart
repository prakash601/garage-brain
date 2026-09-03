/// Shared field validators so every form enforces the same rules
/// (DESIGN.md §5: phone = identity, names need ≥2 chars).
bool isValidCustomerName(String? raw) =>
    raw != null && raw.trim().length >= 2;

/// KM reading is optional; returns the parsed value when usable.
/// Returns null for empty text, non-numeric text, or negative readings.
int? tryParseKm(String? raw) {
  final text = raw?.trim() ?? '';
  if (text.isEmpty) return null;
  final value = int.tryParse(text);
  if (value == null || value < 0) return null;
  return value;
}
