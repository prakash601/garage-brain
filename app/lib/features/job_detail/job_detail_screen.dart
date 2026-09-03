import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/job_number.dart';
import '../../core/widgets/content_frame.dart';
import '../../data/drift/enums.dart';
import '../../data/repositories/job_repository.dart';
import 'job_detail_providers.dart';
import 'whatsapp.dart';

const List<JobStatus> _statusFlow = JobStatus.values;

class JobDetailScreen extends ConsumerStatefulWidget {
  const JobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  final _notesController = TextEditingController();
  String? _loadedJobId;
  bool _advancing = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _maybeSyncNotes(JobDetailData data) {
    if (_loadedJobId != data.job.id) {
      _loadedJobId = data.job.id;
      _notesController.text = data.job.notes ?? '';
    }
  }

  Future<void> _advance(JobDetailData data) async {
    final next = legalNextStatus[data.job.status];
    if (next == null || _advancing) return;
    setState(() => _advancing = true);
    try {
      await ref
          .read(jobDetailProvider(widget.jobId).notifier)
          .advanceStatus();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update status')),
        );
      }
    } finally {
      if (mounted) setState(() => _advancing = false);
    }
  }

  Future<void> _callCustomer(String phone) async {
    final url = Uri(scheme: 'tel', path: phone);
    try {
      await launchUrl(url);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not place call')),
        );
      }
    }
  }
  Future<void> _openWhatsApp(JobDetailData data) async {
    final url = buildWhatsAppReadyUrl(
      phone: data.customer.phone,
      jobNo: formatJobNumber(data.job.jobNo),
      vehicleLabel:
          '${data.vehicle.make} ${data.vehicle.model} (${data.vehicle.numberPlate})',
    );
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(jobDetailProvider(widget.jobId));

    return Scaffold(
      appBar: AppBar(title: const Text('Job Detail')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (data) {
          _maybeSyncNotes(data);
          return ContentFrame(
            child: ListView(
              padding: const EdgeInsets.all(16),
            children: [
              Text(
                formatJobNumber(data.job.jobNo),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                '${data.vehicle.make} ${data.vehicle.model} · '
                '${data.vehicle.numberPlate} · '
                '${data.customer.name} (${data.customer.phone})',
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const Key('call_customer_button'),
                  onPressed: () => _callCustomer(data.customer.phone),
                  icon: const Icon(Icons.call_outlined, size: 18),
                  label: const Text('Call customer'),
                ),
              ),
              if (data.job.complaints.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Complaints: ${data.job.complaints}'),
              ],
              const SizedBox(height: 16),
              _StatusStepper(status: data.job.status),
              const SizedBox(height: 8),
              if (data.job.status != JobStatus.delivered)
                FilledButton.icon(
                  key: Key('advance_${data.job.status.name}'),
                  onPressed:
                      _advancing ? null : () => _advance(data),
                  icon: _advancing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.arrow_forward),
                  label: Text(_advanceLabel(data.job.status)),
                ),
              if (data.job.status == JobStatus.readyForDelivery) ...[
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  key: const Key('whatsapp_ready_button'),
                  onPressed: () => _openWhatsApp(data),
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Notify on WhatsApp'),
                ),
              ],
              const Divider(height: 32),
              Text('Notes', style: Theme.of(context).textTheme.titleMedium),
              TextField(
                key: const Key('job_notes'),
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add notes',
                  border: OutlineInputBorder(),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const Key('save_notes'),
                  onPressed: () => ref
                      .read(jobDetailProvider(widget.jobId).notifier)
                      .saveNotes(_notesController.text),
                  child: const Text('Save notes'),
                ),
              ),
              const Divider(height: 32),
              Text('History',
                  style: Theme.of(context).textTheme.titleMedium),
              if (data.history.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No earlier history found.',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.outline),
                  ),
                )
              else
                ...[
                  for (final entry in data.history)
                    ListTile(
                      dense: true,
                      leading: Icon(entry.isOldBill
                          ? Icons.history
                          : Icons.receipt_long),
                      title: Text(entry.title),
                      subtitle: Text(entry.subtitle),
                      trailing: Text(
                          '${entry.date.day}/${entry.date.month}/${entry.date.year}'),
                    ),
                ],
            ],
            ),
          );
        },
      ),
    );
  }

  String _advanceLabel(JobStatus status) => switch (status) {
        JobStatus.arrived => 'Start work',
        JobStatus.inProgress => 'Mark ready for delivery',
        JobStatus.readyForDelivery => 'Mark delivered',
        JobStatus.delivered => 'Delivered',
      };
}

class _StatusStepper extends StatelessWidget {
  const _StatusStepper({required this.status});

  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    final labels = ['Arrived', 'In Progress', 'Ready', 'Delivered'];
    return Row(
      key: const Key('status_stepper'),
      children: [
        for (var i = 0; i < _statusFlow.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  key: Key('stepper_${_statusFlow[i].name}'),
                  radius: 12,
                  backgroundColor: i <= status.index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: i < status.index || status == JobStatus.delivered
                      ? Icon(Icons.check,
                          size: 14,
                          color:
                              Theme.of(context).colorScheme.onPrimary)
                      : null,
                ),
                const SizedBox(height: 4),
                Text(labels[i], style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          if (i < _statusFlow.length - 1)
            Container(
              width: 16,
              height: 2,
              color: i < status.index
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
            ),
        ],
      ],
    );
  }
}
