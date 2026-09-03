import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../drift/app_database.dart';
import '../drift/enums.dart';

class IllegalStatusTransitionException implements Exception {
  IllegalStatusTransitionException(this.from, this.to);

  final JobStatus from;
  final JobStatus to;

  @override
  String toString() =>
      'Illegal status transition: $from -> $to (linear flow only, DESIGN.md §5)';
}

class JobNotCloseableException implements Exception {
  JobNotCloseableException(this.status, this.closed);

  final JobStatus status;
  final bool closed;

  @override
  String toString() => 'Job cannot be closed in state $status (closed=$closed); '
      'manual close requires Delivered (DESIGN.md §7)';
}

/// Linear flow only: Arrived → InProgress → ReadyForDelivery → Delivered.
const Map<JobStatus, JobStatus?> legalNextStatus = {
  JobStatus.arrived: JobStatus.inProgress,
  JobStatus.inProgress: JobStatus.readyForDelivery,
  JobStatus.readyForDelivery: JobStatus.delivered,
  JobStatus.delivered: null,
};

class JobRepository {
  JobRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  /// Creates a job with a client UUID; `job_no` is a local placeholder
  /// (local max + 1) — the authoritative number comes from the Postgres
  /// sequence during sync (DESIGN.md §5 job numbering note).
  Future<JobCard> createJob({
    required String vehicleNumberPlate,
    required String customerId,
    required String complaints,
    int? kmReading,
    String? notes,
    String? createdBy,
  }) async {
    final maxRow =
        await _db.customSelect('SELECT MAX(job_no) AS m FROM job_cards').getSingle();
    final nextNo = (maxRow.data['m'] as int? ?? 0) + 1;

    return _db.into(_db.jobCards).insertReturning(
          JobCardsCompanion.insert(
            id: _uuid.v4(),
            jobNo: nextNo,
            vehicleNumberPlate: vehicleNumberPlate,
            customerId: customerId,
            complaints: complaints,
            status: JobStatus.arrived,
            kmReading: Value(kmReading),
            notes: Value(notes),
            createdBy: Value(createdBy),
          ),
        );
  }

  Future<JobCard> byId(String id) =>
      (_db.select(_db.jobCards)..where((j) => j.id.equals(id))).getSingle();

  Future<JobCard> transitionStatus(String jobId, JobStatus target) async {
    final job = await byId(jobId);
    if (legalNextStatus[job.status] != target) {
      throw IllegalStatusTransitionException(job.status, target);
    }
    return _write(
      jobId,
      JobCardsCompanion(status: Value(target)),
    );
  }

  /// Manual close is only legal on Delivered jobs that are not yet closed
  /// (DESIGN.md §7).
  Future<JobCard> closeJob(String jobId) async {
    final job = await byId(jobId);
    if (job.status != JobStatus.delivered || job.closed) {
      throw JobNotCloseableException(job.status, job.closed);
    }
    return _write(jobId, const JobCardsCompanion(closed: Value(true)));
  }

  Future<JobCard> updateNotes(String jobId, String? notes) =>
      _write(jobId, JobCardsCompanion(notes: Value(notes)));

  Future<JobCard> _write(String jobId, JobCardsCompanion changes) async {
    final rows =
        await (_db.update(_db.jobCards)..where((j) => j.id.equals(jobId)))
            .writeReturning(changes.copyWith(
      updatedAt: Value(DateTime.now()),
      synced: const Value(false),
      syncedAt: const Value(null),
    ));
    return rows.single;
  }
}
