import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/drift/app_database.dart';
import '../../data/drift/database_provider.dart';
import '../../data/drift/enums.dart';
import '../../data/repositories/job_repository.dart';

/// Emits `true` while the device has no connectivity.
final offlineProvider = StreamProvider<bool>(
  (ref) {
    final connectivity = ref.watch(connectivityFactoryProvider);
    return connectivity().onConnectivityChanged
        .map((results) => results.contains(ConnectivityResult.none));
  },
);

typedef ConnectivityFactory = Connectivity Function();

final connectivityFactoryProvider =
    Provider<ConnectivityFactory>((ref) => Connectivity.new);

class DashboardJob {
  const DashboardJob({
    required this.jobId,
    required this.jobNo,
    required this.plate,
    required this.customerName,
    required this.status,
    required this.closed,
    required this.createdAt,
    required this.vehicleType,
  });

  final String jobId;
  final int jobNo;
  final String plate;
  final String customerName;
  final JobStatus status;
  final bool closed;
  final DateTime createdAt;
  final VehicleType vehicleType;

  bool get isPending =>
      status == JobStatus.arrived ||
      status == JobStatus.inProgress ||
      status == JobStatus.readyForDelivery;

  bool get isCompleted => status == JobStatus.delivered;
}

DateTime startOfToday() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

Stream<List<DashboardJob>> watchTodayJobs(AppDatabase db) {
  final query = db.select(db.jobCards).join([
    innerJoin(
        db.customers, db.customers.id.equalsExp(db.jobCards.customerId)),
    innerJoin(db.vehicles,
        db.vehicles.numberPlate.equalsExp(db.jobCards.vehicleNumberPlate)),
  ])
    ..where(db.jobCards.createdAt
        .isBiggerOrEqualValue(startOfToday()))
    ..orderBy([OrderingTerm.desc(db.jobCards.createdAt)]);

  return query.watch().map((rows) => [
        for (final row in rows)
          () {
            final job = row.readTable(db.jobCards);
            final customer = row.readTable(db.customers);
            final vehicle = row.readTable(db.vehicles);
            return DashboardJob(
              jobId: job.id,
              jobNo: job.jobNo,
              plate: job.vehicleNumberPlate,
              customerName: customer.name,
              status: job.status,
              closed: job.closed,
              createdAt: job.createdAt,
              vehicleType: vehicle.vehicleType,
            );
          }(),
      ]);
}

final todayJobsProvider = StreamProvider<List<DashboardJob>>(
  (ref) => watchTodayJobs(ref.watch(appDatabaseProvider)),
);

final jobRepositoryProvider =
    Provider<JobRepository>((ref) => JobRepository(ref.watch(appDatabaseProvider)));
