import 'package:drift/drift.dart';

import '../../core/utils/job_number.dart';
import '../../core/utils/phone.dart';
import '../../core/utils/plate.dart';
import '../../data/drift/app_database.dart';
import '../../data/drift/enums.dart';

class TimelineHit {
  const TimelineHit({
    required this.date,
    required this.headline,
    required this.subline,
    required this.isOldBill,
    this.jobId,
  });

  final DateTime date;
  final String headline;
  final String subline;
  final bool isOldBill;
  final String? jobId;

  bool get isJob => jobId != null;
}

/// Unified plate-fragment AND phone-digit lookup reading Drift only
/// (<3s requirement, DESIGN.md §6 S3). Jobs and old_bills are merged into a
/// single recent-first timeline.
class SearchService {
  SearchService(this._db);

  final AppDatabase _db;

  static const int _minPhoneDigits = 4;

  /// LIKE wildcards (`%`, `_`, `\`) are never meaningful in a plate/phone/
  /// name query — strip them so user input can't widen the match.
  static String likeSafe(String input) =>
      input.replaceAll(RegExp(r'[%_\\]'), '');

  Future<List<TimelineHit>> search(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return const [];

    final normalized = likeSafe(normalizePlate(query));
    final hasPlateFragment =
        normalized.isNotEmpty && RegExp(r'^[A-Z0-9]+$').hasMatch(normalized);
    final digits = likeSafe(normalizePhone(query));
    final hasPhoneDigits = digits.length >= _minPhoneDigits;
    final nameTerm = likeSafe(query.trim());
    final hasNameTerm = nameTerm.length >= 2;
    if (!hasPlateFragment && !hasPhoneDigits && !hasNameTerm) {
      return const [];
    }

    Expression<bool> jobWhere;
    Expression<bool> billWhere;
    Expression<bool> jobNameClause(Expression<bool> base) => hasNameTerm
        ? base | _db.customers.name.like('%$nameTerm%')
        : base;
    Expression<bool> billNameClause(Expression<bool> base) => hasNameTerm
        ? base | _db.oldBills.customerName.like('%$nameTerm%')
        : base;
    if (hasPlateFragment && hasPhoneDigits) {
      jobWhere = jobNameClause(
        _db.vehicles.numberPlate.like('%$normalized%') |
            _db.customers.phone.like('%$digits%'),
      );
      billWhere = billNameClause(
        _db.oldBills.vehicleNumberPlate.like('%$normalized%') |
            _db.oldBills.customerPhone.like('%$digits%') |
            _db.oldBills.billNo.like('%$normalized%'),
      );
    } else if (hasPlateFragment) {
      jobWhere = jobNameClause(
        _db.vehicles.numberPlate.like('%$normalized%'),
      );
      billWhere = billNameClause(
        _db.oldBills.billNo.like('%$normalized%') |
            _db.oldBills.vehicleNumberPlate.like('%$normalized%'),
      );
    } else if (hasPhoneDigits) {
      jobWhere = jobNameClause(_db.customers.phone.like('%$digits%'));
      billWhere = billNameClause(
        _db.oldBills.customerPhone.like('%$digits%'),
      );
    } else {
      jobWhere = _db.customers.name.like('%$nameTerm%');
      billWhere = _db.oldBills.customerName.like('%$nameTerm%');
    }

    final hits = [
      ...await _jobHits(jobWhere),
      ...await _oldBillHits(billWhere),
    ];

    hits.sort((a, b) => b.date.compareTo(a.date));
    return hits;
  }

  Future<List<TimelineHit>> _jobHits(Expression<bool> where) async {
    final query = _db.select(_db.jobCards).join([
      innerJoin(
          _db.customers, _db.customers.id.equalsExp(_db.jobCards.customerId)),
      innerJoin(_db.vehicles,
          _db.vehicles.numberPlate.equalsExp(_db.jobCards.vehicleNumberPlate)),
    ])
      ..where(where)
      ..orderBy([OrderingTerm.desc(_db.jobCards.createdAt)])
      ..limit(50);

    final rows = await query.get();
    return [
      for (final row in rows)
        () {
          final job = row.readTable(_db.jobCards);
          final vehicle = row.readTable(_db.vehicles);
          final customer = row.readTable(_db.customers);
          return TimelineHit(
            date: job.createdAt,
            headline:
                '${formatJobNumber(job.jobNo)} · ${vehicle.numberPlate}',
            subline: '${customer.name} — ${job.complaints} '
                '(${vehicleTypeLabel(vehicle.vehicleType)})',
            jobId: job.id,
            isOldBill: false,
          );
        }(),
    ];
  }

  Future<List<TimelineHit>> _oldBillHits(Expression<bool> where) async {
    final rows = await (_db.select(_db.oldBills)
          ..where((b) => where)
          ..orderBy([(b) => OrderingTerm.desc(b.billDate)])
          ..limit(50))
        .get();
    return [
      for (final bill in rows)
        TimelineHit(
          date: bill.billDate,
          headline:
              '${bill.billNo} · ${bill.vehicleNumberPlate ?? '(no plate)'}',
          subline:
              '${bill.customerName} (${vehicleTypeLabel(bill.vehicleCategory)})',
          isOldBill: true,
        ),
    ];
  }
}
