import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/backup/backup_providers.dart';
import '../../core/widgets/content_frame.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  String? _lastExportPath;
  String? _lastCopyPath;
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final service = ref.read(backupServiceProvider);
      if (kIsWeb) {
        final json = await service.exportJsonString();
        if (!mounted) return;
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Weekly JSON export (Web)'),
            content: SingleChildScrollView(child: SelectableText(json)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export ready — copy from dialog')),
        );
        return;
      }
      final file = await service.writeExportFile();
      setState(() => _lastExportPath = file.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export saved: ${file.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copyDb() async {
    setState(() => _busy = true);
    try {
      final service = ref.read(backupServiceProvider);
      final file = await service.copyDatabaseFile();
      if (file == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No database file found (in-memory / web) — '
                  'use JSON export instead')),
        );
        return;
      }
      setState(() => _lastCopyPath = file.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup copied: ${file.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share(String path) async {
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path)], text: 'Workshop OS backup'),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share failed: $e')),
      );
    }
  }

  Future<void> _restoreFromPicker() async {
    setState(() => _busy = true);
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (picked.isEmpty) return;
      final file = picked.first;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read that file')),
        );
        return;
      }
      final jsonStr = utf8.decode(bytes);
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restore backup?'),
          content: Text(
              'This merges ${file.name} into the local database '
              '(existing rows are kept, matching IDs are updated).'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('confirm_restore'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restore'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      await ref
          .read(backupServiceProvider)
          .restoreFromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restored ${file.name}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin — Backups')),
      body: ContentFrame(
        child: ListView(
          padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Backups & Data Safety',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'Workshop OS keeps a local Drift SQLite file on-device '
                    'and creates periodic copies in the app backups folder '
                    '(scheduled daily). A weekly JSON export of all tables is '
                    'also written to the same folder for owner download/share. '
                    'See README for restore steps.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('export_json_button'),
            onPressed: _busy ? null : _export,
            icon: const Icon(Icons.download_outlined),
            label: Text(_busy ? 'Working…' : 'Export JSON (all tables)'),
          ),
          if (_lastExportPath != null) ...[
            const SizedBox(height: 8),
            SelectableText('Last export: $_lastExportPath',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            OutlinedButton.icon(
              key: const Key('share_export_button'),
              onPressed: () => _share(_lastExportPath!),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share export'),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            key: const Key('copy_db_button'),
            onPressed: _busy ? null : _copyDb,
            icon: const Icon(Icons.copy_outlined),
            label: Text(_busy ? 'Working…' : 'Copy database file (local backup)'),
          ),
          if (_lastCopyPath != null) ...[
            const SizedBox(height: 8),
            SelectableText('Last copy: $_lastCopyPath',
                style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('restore_button'),
            onPressed: _busy ? null : _restoreFromPicker,
            icon: const Icon(Icons.restore_outlined),
            label: Text(_busy ? 'Working…' : 'Restore from JSON…'),
          ),
          const SizedBox(height: 24),
          const Divider(),
          Text('What gets exported?',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          const Text(
            '• customers\n'
            '• vehicles\n'
            '• car_ownership_history\n'
            '• job_cards\n'
            '• old_bills\n'
            '• recommendation_queue\n\n'
            'All rows are included; secrets and Supabase auth are not part of '
            'the export.',
          ),
        ],
        ),
      ),
    );
  }
}
