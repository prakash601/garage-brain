import 'package:flutter/material.dart';

import '../../data/drift/enums.dart';
import '../utils/plate.dart';

/// Single home for semantic colors so no screen hardcodes raw [Colors]
/// values that break in dark mode (Phase 4).
///
/// Hues keep their real-world meaning (green = good/classic plate,
/// amber = check it, red = invalid) while the exact shade adapts to the
/// active brightness.

Color plateFlagColor(BuildContext context, PlateFlag flag) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (flag) {
    PlateFlag.green => dark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
    PlateFlag.amber => dark ? const Color(0xFFFFD54F) : const Color(0xFFB26A00),
    PlateFlag.red => Theme.of(context).colorScheme.error,
  };
}

class JobStatusChipStyle {
  const JobStatusChipStyle({required this.label, required this.background});

  final String label;
  final Color background;
}

JobStatusChipStyle jobStatusChipStyle(
    BuildContext context, JobStatus status) {
  final scheme = Theme.of(context).colorScheme;
  return switch (status) {
    JobStatus.arrived => JobStatusChipStyle(
        label: 'Arrived', background: scheme.tertiaryContainer),
    JobStatus.inProgress => JobStatusChipStyle(
        label: 'In Progress', background: scheme.secondaryContainer),
    JobStatus.readyForDelivery => JobStatusChipStyle(
        label: 'Ready', background: scheme.primaryContainer),
    JobStatus.delivered => JobStatusChipStyle(
        label: 'Delivered', background: scheme.inversePrimary),
  };
}
