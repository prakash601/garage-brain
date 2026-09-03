import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/status_colors.dart';
import '../../core/utils/job_number.dart';
import '../../core/utils/phone.dart';
import '../../core/utils/plate.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/content_frame.dart';
import '../../data/drift/database_provider.dart';
import '../../data/drift/enums.dart';
import '../../routing/app_router.dart';
import 'create_job_service.dart';
import 'makes_provider.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _modelController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _complaintsController = TextEditingController();
  final _kmController = TextEditingController();

  VehicleType _vehicleType = VehicleType.twoWheeler;
  FuelType? _fuelType;
  String? _make;
  bool _saving = false;
  String? _openJobId;
  int? _openJobNo;

  CreateJobService get _service =>
      CreateJobService(ref.read(appDatabaseProvider));

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _complaintsController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  Future<void> _lookupCustomer() async {
    final phone = normalizePhone(_phoneController.text);
    if (!isValidPhone(phone)) return;
    final existing = await _service.findCustomerByPhone(phone);
    if (!mounted) return;
    if (existing != null && _nameController.text.trim().isEmpty) {
      setState(() => _nameController.text = existing.name);
    }
  }

  /// Returning vehicles pre-fill type/make/model/fuel and their current
  /// customer so repeat visits take seconds, not a minute.
  Future<void> _lookupVehicle() async {
    final plate = normalizePlate(_plateController.text);
    if (classifyPlate(plate) == PlateFlag.red || plate.length < 6) return;
    final existing = await _service.findVehicleByPlate(plate);
    final openJob = await _service.findOpenJobByPlate(plate);
    if (!mounted) return;
    final needsOwner =
        existing?.currentCustomerId != null &&
        _phoneController.text.trim().isEmpty;
    final owner = needsOwner
        ? await _service.findCustomerById(existing!.currentCustomerId!)
        : null;
    if (!mounted) return;
    setState(() {
      _openJobId = openJob?.id;
      _openJobNo = openJob?.jobNo;
      if (existing != null) {
        _vehicleType = existing.vehicleType;
        _make = existing.make;
        _modelController.text = existing.model;
        _fuelType = existing.fuelType;
      }
      if (owner != null) {
        _phoneController.text = owner.phone;
        if (_nameController.text.trim().isEmpty) {
          _nameController.text = owner.name;
        }
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final km = tryParseKm(_kmController.text);
      final job = await _service.createJob(
        plate: normalizePlate(_plateController.text),
        vehicleType: _vehicleType,
        make: _make ?? '',
        model: _modelController.text,
        fuelType: _fuelType,
        name: _nameController.text,
        phone: normalizePhone(_phoneController.text),
        complaints: _complaintsController.text,
        kmReading: km,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: messenger.hideCurrentSnackBar,
            child: const Text('Job created'),
          ),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            key: const Key('view_created_job'),
            label: 'View',
            onPressed: () {
              messenger.hideCurrentSnackBar();
              GoRouter.maybeOf(context)
                  ?.push('${RoutePaths.job}/${job.id}');
            },
          ),
        ),
      );
      _resetForm();
    } on CreateJobValidationException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.errors.values.join('\n'))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Keep name/phone warm after a save so back-to-back jobs for one customer
  /// (or fleet) don't need retyping; vehicle + complaint fields reset.
  void _resetForm() {
    _plateController.clear();
    _modelController.clear();
    _complaintsController.clear();
    _kmController.clear();
    setState(() {
      _vehicleType = VehicleType.twoWheeler;
      _fuelType = null;
      _make = null;
    });
  }

  Widget? _plateFlag(BuildContext context) {
    final text = normalizePlate(_plateController.text);
    if (text.isEmpty) return null;
    final flag = classifyPlate(text);
    return Icon(
      Icons.circle,
      size: 14,
      key: Key('job_plate_flag_${flag.name}'),
      color: plateFlagColor(context, flag),
    );
  }

  @override
  Widget build(BuildContext context) {
    final makes = ref.watch(makesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Job')),
      body: Form(
        key: _formKey,
        child: ContentFrame(
          child: ListView(
            padding: const EdgeInsets.all(16),
          children: [
            Text('Vehicle', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('job_plate'),
              controller: _plateController,
              decoration: InputDecoration(
                labelText: 'Number plate',
                suffixIcon: _plateFlag(context),
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {
                _openJobId = null;
                _openJobNo = null;
              }),
              onEditingComplete: () async {
                FocusScope.of(context).unfocus();
                await _lookupVehicle();
              },
              validator: (_) {
                if (classifyPlate(_plateController.text) == PlateFlag.red) {
                  return 'Invalid plate characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            if (_openJobId != null && _openJobNo != null)
              Card(
                key: const Key('open_job_warning'),
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.warning_amber_outlined),
                  title: Text(
                      '${formatJobNumber(_openJobNo!)} is already open for this plate'),
                  trailing: TextButton(
                    key: const Key('view_open_job'),
                    onPressed: () => GoRouter.maybeOf(context)
                        ?.push('${RoutePaths.job}/$_openJobId'),
                    child: const Text('View'),
                  ),
                ),
              ),
            if (_openJobId != null) const SizedBox(height: 12),
            SegmentedButton<VehicleType>(
              segments: const [
                ButtonSegment(value: VehicleType.twoWheeler, label: Text('2W')),
                ButtonSegment(
                    value: VehicleType.fourWheeler, label: Text('4W')),
              ],
              selected: {_vehicleType},
              onSelectionChanged: (selection) =>
                  setState(() => _vehicleType = selection.first),
            ),
            const SizedBox(height: 12),
            makes.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Makes unavailable: $error'),
              data: (list) => DropdownButtonFormField<String>(
                key: const Key('job_make'),
                initialValue: _make,
                decoration: const InputDecoration(labelText: 'Make'),
                items: [
                  for (final make in list)
                    DropdownMenuItem(value: make, child: Text(make)),
                ],
                validator: (value) => value == null ? 'Select a make' : null,
                onChanged: (value) => setState(() => _make = value),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('job_model'),
              controller: _modelController,
              decoration: const InputDecoration(labelText: 'Model'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter the model'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<FuelType>(
              key: const Key('job_fuel'),
              initialValue: _fuelType,
              decoration: const InputDecoration(labelText: 'Fuel type'),
              items: [
                for (final fuel in FuelType.values)
                  DropdownMenuItem(
                    value: fuel,
                    child: Text(
                      fuel.name[0].toUpperCase() + fuel.name.substring(1),
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _fuelType = value),
            ),
            const Divider(height: 32),
            Text('Customer', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('customer_phone'),
              controller: _phoneController,
              decoration:
                  const InputDecoration(labelText: 'Phone number'),
              keyboardType: TextInputType.phone,
              onEditingComplete: () async {
                FocusScope.of(context).unfocus();
                await _lookupCustomer();
              },
              validator: (value) => isValidRawPhone(value ?? '')
                  ? null
                  : 'Enter a valid mobile number',
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('customer_name'),
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
              validator: (value) => isValidCustomerName(value)
                  ? null
                  : 'Enter the customer name',
            ),
            const Divider(height: 32),
            Text('Job', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('job_complaints'),
              controller: _complaintsController,
              decoration: const InputDecoration(
                labelText: 'Complaints',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Describe the complaint'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('job_km'),
              controller: _kmController,
              decoration:
                  const InputDecoration(labelText: 'KM reading (optional)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('save_job'),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: const Text('Save Job'),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
