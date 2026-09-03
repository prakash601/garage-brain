import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../drift/app_database.dart';
import 'ownership_repository.dart';

/// Phone IS the identity: an existing phone merges into the same row
/// (name refreshed, same id), never a second customer (DESIGN.md §5).
class CustomerRepository {
  CustomerRepository(this._db, {OwnershipRepository? ownershipRepository})
      : _ownership = ownershipRepository;

  final AppDatabase _db;
  final Uuid _uuid = const Uuid();
  final OwnershipRepository? _ownership;

  Future<Customer> upsertByNameAndPhone({
    required String name,
    required String phone,
  }) async {
    final existing =
        await (_db.select(_db.customers)..where((c) => c.phone.equals(phone)))
            .getSingleOrNull();

    if (existing == null) {
      return _db.into(_db.customers).insertReturning(
            CustomersCompanion.insert(
              id: _uuid.v4(),
              name: name,
              phone: phone,
            ),
          );
    }

    if (existing.name == name) return existing;

    final rows =
        await (_db.update(_db.customers)..where((c) => c.id.equals(existing.id)))
            .writeReturning(
      CustomersCompanion(
        name: Value(name),
        synced: const Value(false),
        syncedAt: const Value(null),
      ),
    );
    return rows.single;
  }

  Future<Customer?> findByPhone(String phone) =>
      (_db.select(_db.customers)..where((c) => c.phone.equals(phone)))
          .getSingleOrNull();

  OwnershipRepository? get ownershipRepository => _ownership;
}
