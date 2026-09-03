import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/phone.dart';
import '../../core/utils/plate.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/content_frame.dart';
import '../../data/drift/app_database.dart';
import '../../data/drift/database_provider.dart';
import '../../data/drift/enums.dart';
import '../../data/repositories/old_bills_repository.dart';

final _oldBillsRepoProvider = Provider<OldBillsRepository>(
  (ref) => OldBillsRepository(ref.watch(appDatabaseProvider)),
);

final _recentBillsProvider = FutureProvider.autoDispose<List<OldBill>>(
  (ref) => ref.watch(_oldBillsRepoProvider).recent(),
);

class OldBillsScreen extends ConsumerStatefulWidget {
  const OldBillsScreen({super.key});

  @override
  ConsumerState<OldBillsScreen> createState() => _OldBillsScreenState();
}

class _OldBillsScreenState extends ConsumerState<OldBillsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _billNoController = TextEditingController();
  final _plateController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _billDate = DateTime.now();
  VehicleType _category = VehicleType.twoWheeler;
  String? _duplicateError;
  bool _saving = false;

  OldBillsRepository get _repo => ref.read(_oldBillsRepoProvider);

  @override
  void dispose() {
    _billNoController.dispose();
    _plateController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _billDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _billDate = picked);
  }

  /// Save-and-next: clears per-bill fields, keeps plate/customer AND the
  /// bill date warm so consecutive records from the same paper book and
  /// the same day stay fast to enter.
  void _nextRecord() {
    _billNoController.clear();
    _notesController.clear();
    setState(() => _duplicateError = null);
  }

  /// Save-and-done: full reset back to a blank form. The Import tab is a
  /// bottom-nav branch, so there is nowhere to pop to — staying put with
  /// a confirmation is the correct end state.
  void _resetAll() {
    _billNoController.clear();
    _plateController.clear();
    _nameController.clear();
    _phoneController.clear();
    _notesController.clear();
    setState(() {
      _billDate = DateTime.now();
      _duplicateError = null;
      _category = VehicleType.twoWheeler;
    });
  }

  Future<void> _checkDuplicate() async {
    final billNo = _billNoController.text.trim();
    if (billNo.isEmpty) return;
    final exists = await _repo.billNoExists(billNo);
    if (!mounted) return;
    setState(() => _duplicateError =
        exists ? 'Bill no $billNo already exists' : null);
  }

  Future<void> _save({required bool next}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _duplicateError = null;
    });
    try {
      await _repo.addBill(
        billNo: _billNoController.text.trim(),
        billDate: _billDate,
        vehicleCategory: _category,
        customerName: _nameController.text.trim(),
        vehicleNumberPlate: normalizePlate(_plateController.text),
        customerPhone:
            _phoneController.text.isEmpty
                ? null
                : normalizePhone(_phoneController.text),
        notes: _notesController.text.isEmpty
            ? null
            : _notesController.text,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          key: const Key('old_bill_saved_snackbar'),
          content: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: messenger.hideCurrentSnackBar,
            child: Text('Saved ${_billNoController.text.trim()}'),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      ref.invalidate(_recentBillsProvider);
      if (next) {
        _nextRecord();
      } else {
        _resetAll();
      }
    } on DuplicateBillNoException catch (error) {
      setState(() => _duplicateError =
          'Bill no ${error.billNo} already exists');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Old Bills')),
      body: Form(
        key: _formKey,
        child: ContentFrame(
          child: ListView(
            padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('bill_no'),
              controller: _billNoController,
              decoration: InputDecoration(
                labelText: 'Bill number',
                errorText: _duplicateError,
              ),
              onEditingComplete: () async {
                FocusScope.of(context).unfocus();
                await _checkDuplicate();
              },
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Enter the bill number'
                      : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_billDate.day}/${_billDate.month}/${_billDate.year}',
                    key: const Key('bill_date_label'),
                  ),
                ),
                TextButton.icon(
                  key: const Key('pick_bill_date'),
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Date'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('bill_plate'),
              controller: _plateController,
              decoration:
                  const InputDecoration(labelText: 'Plate (optional)'),
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) {},
              autovalidateMode: AutovalidateMode.disabled,
              validator: (value) {
                final raw = value?.trim() ?? '';
                if (raw.isEmpty) return null;
                if (classifyPlate(raw) == PlateFlag.red) {
                  return 'Invalid plate characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            SegmentedButton<VehicleType>(
              segments: const [
                ButtonSegment(value: VehicleType.twoWheeler, label: Text('2W')),
                ButtonSegment(
                    value: VehicleType.fourWheeler, label: Text('4W')),
              ],
              selected: {_category},
              onSelectionChanged: (selection) =>
                  setState(() => _category = selection.first),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('bill_customer_name'),
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Customer name'),
              textCapitalization: TextCapitalization.words,
              validator: (value) => isValidCustomerName(value)
                  ? null
                  : 'Enter the customer name',
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('bill_customer_phone'),
              controller: _phoneController,
              decoration: const InputDecoration(
                  labelText: 'Phone (optional)'),
              keyboardType: TextInputType.phone,
              validator: (value) {
                final raw = value?.trim() ?? '';
                if (raw.isEmpty) return null;
                if (!isValidRawPhone(raw)) {
                  return 'Enter a valid mobile number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('bill_notes'),
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('save_bill_next'),
                    onPressed:
                        _saving ? null : () => _save(next: true),
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.playlist_add),
                    label: const Text('Save & Next'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const Key('save_bill_done'),
                    onPressed:
                        _saving ? null : () => _save(next: false),
                    child: const Text('Save & Done'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const _RecentImports(),
          ],
          ),
        ),
      ),
    );
  }
}

class _RecentImports extends ConsumerWidget {
  const _RecentImports();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(_recentBillsProvider);
    return recent.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (bills) {
        if (bills.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent imports (${bills.length})',
              key: const Key('recent_bills_header'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final bill in bills)
              ListTile(
                key: Key('recent_bill_${bill.billNo}'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history, size: 20),
                title: Text(
                    '${bill.billNo} · ${bill.vehicleNumberPlate ?? '(no plate)'}'),
                subtitle: Text(bill.customerName),
                trailing: Text(
                    '${bill.billDate.day}/${bill.billDate.month}/${bill.billDate.year}'),
              ),
          ],
        );
      },
    );
  }
}
