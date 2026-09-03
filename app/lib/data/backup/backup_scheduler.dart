import 'dart:async';

import 'backup_service.dart';

class BackupScheduler {
  BackupScheduler(
    this._service, {
    this.fileCopyInterval = const Duration(days: 1),
    this.exportInterval = const Duration(days: 7),
  });

  final BackupService _service;
  final Duration fileCopyInterval;
  final Duration exportInterval;

  Timer? _copyTimer;
  Timer? _exportTimer;
  bool _running = false;

  Future<void> start() async {
    if (_running) return;
    _running = true;
    await _runCopy();
    await _runExport();
    _copyTimer = Timer.periodic(fileCopyInterval, (_) => _runCopy());
    _exportTimer = Timer.periodic(exportInterval, (_) => _runExport());
  }

  Future<void> stop() async {
    _copyTimer?.cancel();
    _exportTimer?.cancel();
    _copyTimer = null;
    _exportTimer = null;
    _running = false;
  }

  Future<void> _runCopy() async {
    try {
      await _service.copyDatabaseFile();
    } catch (_) {}
  }

  Future<void> _runExport() async {
    try {
      await _service.writeExportFile();
    } catch (_) {}
  }

  bool get isRunning => _running;
}
