import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/drift/app_database.dart';
import '../../data/drift/database_provider.dart';
import '../../data/repositories/job_repository.dart';

final jobRepositoryRefProvider =
    Provider<JobRepository>((ref) => JobRepository(ref.watch(appDatabaseProvider)));

class JobDetailData {
  const JobDetailData({
    required this.job,
    required this.customer,
    required this.vehicle,
    required this.history,
  });

  final JobCard job;
  final Customer customer;
  final Vehicle vehicle;
  final List<HistoryEntry> history;
}

class HistoryEntry {
  const HistoryEntry({
    required this.date,
    required this.title,
    required this.subtitle,
    this.isOldBill = false,
  });

  final DateTime date;
  final String title;
  final String subtitle;
  final bool isOldBill;
}

class JobDetailController extends AsyncNotifier<JobDetailData> {
  JobDetailController(this.jobId);

  final String jobId;

  @override
  Future<JobDetailData> build() => _load();

  Future<JobDetailData> _load() async {
    final db = ref.read(appDatabaseProvider);

    final query = db.select(db.jobCards).join([
      innerJoin(
          db.customers, db.customers.id.equalsExp(db.jobCards.customerId)),
      innerJoin(db.vehicles,
          db.vehicles.numberPlate.equalsExp(db.jobCards.vehicleNumberPlate)),
    ])
      ..where(db.jobCards.id.equals(jobId));

    final rows = await query.getSingle();
    final job = rows.readTable(db.jobCards);
    final customer = rows.readTable(db.customers);
    final vehicle = rows.readTable(db.vehicles);

    final history = <HistoryEntry>[];

    final relatedJobs = await (db.select(db.jobCards)
          ..where((j) =>
              j.vehicleNumberPlate.equals(vehicle.numberPlate) &
              j.id.isNotIn([job.id]))
          ..orderBy([(j) => OrderingTerm.desc(j.createdAt)])
          ..limit(20))
        .get();
    history.addAll([
      for (final j in relatedJobs)
        HistoryEntry(
          date: j.createdAt,
          title: 'Job #${j.jobNo}',
          subtitle: j.complaints,
        ),
    ]);

    final bills = await (db.select(db.oldBills)
          ..where((b) =>
              b.vehicleNumberPlate.equals(vehicle.numberPlate) |
              b.customerPhone.equalsNullable(customer.phone))
          ..orderBy([(b) => OrderingTerm.desc(b.billDate)])
          ..limit(20))
        .get();
    history.addAll([
      for (final b in bills)
        HistoryEntry(
          date: b.billDate,
          title: 'Bill ${b.billNo}',
          subtitle:
              '${b.customerName}${b.notes == null ? '' : ' — ${b.notes}'}',
          isOldBill: true,
        ),
    ]);

    history.sort((a, b) => b.date.compareTo(a.date));

    return JobDetailData(
      job: job,
      customer: customer,
      vehicle: vehicle,
      history: history,
    );
  }

  Future<void> advanceStatus() async {
    final current = state.value;
    if (current == null) return;
    await ref
        .read(jobRepositoryRefProvider)
        .transitionStatus(current.job.id, legalNextStatus[current.job.status]!);
    state = await AsyncValue.guard(() => _load());
  }

  Future<void> saveNotes(String notes) async {
    await ref.read(jobRepositoryRefProvider).updateNotes(jobId, notes);
    state = await AsyncValue.guard(() => _load());
  }
}

final jobDetailProvider = AsyncNotifierProvider.family<JobDetailController,
    JobDetailData, String>(JobDetailController.new);
