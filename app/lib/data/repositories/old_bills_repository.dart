import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../drift/app_database.dart';
import '../drift/enums.dart';

class DuplicateBillNoException implements Exception {
  DuplicateBillNoException(this.billNo);

  final String billNo;

  @override
  String toString() => 'Duplicate bill_no: $billNo';
}

class OldBillsRepository {
  OldBillsRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Future<bool> billNoExists(String billNo) =>
      (_db.select(_db.oldBills)..where((b) => b.billNo.equals(billNo)))
          .getSingleOrNull()
          .then((row) => row != null);

  /// Newest imports first so the entry screen doubles as a quick
  /// did-I-already-enter-this ledger check.
  Future<List<OldBill>> recent({int limit = 20}) =>
      (_db.select(_db.oldBills)
            ..orderBy([(b) => OrderingTerm.desc(b.createdAt)])
            ..limit(limit))
          .get();

  /// Rejects duplicates inline via typed exception (bill_no is unique,
  /// DESIGN.md §5).
  Future<OldBill> addBill({
    required String billNo,
    required DateTime billDate,
    required VehicleType vehicleCategory,
    required String customerName,
    String? vehicleNumberPlate,
    String? customerPhone,
    String? notes,
  }) async {
    if (await billNoExists(billNo)) {
      throw DuplicateBillNoException(billNo);
    }
    return _db.into(_db.oldBills).insertReturning(
          OldBillsCompanion.insert(
            id: _uuid.v4(),
            billNo: billNo,
            billDate: billDate,
            vehicleCategory: vehicleCategory,
            customerName: customerName,
            vehicleNumberPlate: Value(vehicleNumberPlate),
            customerPhone: Value(customerPhone),
            notes: Value(notes),
          ),
        );
  }
}
