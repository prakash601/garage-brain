import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/data/repositories/customer_repository.dart';
import 'package:workshop_os/data/drift/app_database.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  late CustomerRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = CustomerRepository(db);
  });

  tearDown(() async => db.close());

  group('CustomerRepository.upsertByNameAndPhone', () {
    test('new phone inserts fresh customer with client UUID', () async {
      final c = await repo.upsertByNameAndPhone(
        name: 'Ramesh Kumar',
        phone: '9876543210',
      );

      expect(c.phone, '9876543210');
      expect(c.name, 'Ramesh Kumar');
      expect(c.id.length, 36);
      expect(c.synced, false);
    });

    test('duplicate phone merges into same row (phone is identity)',
        () async {
      final first = await repo.upsertByNameAndPhone(
        name: 'Ramesh',
        phone: '9876543210',
      );
      final second = await repo.upsertByNameAndPhone(
        name: 'Ramesh Kumar',
        phone: '9876543210',
      );

      expect(second.id, first.id);
      expect(second.name, 'Ramesh Kumar');

      final all = await db.select(db.customers).get();
      expect(all, hasLength(1));
    });

    test('same name re-upsert is a no-op that stays unsynced', () async {
      await seedCustomer(db);

      final c = await repo.upsertByNameAndPhone(
        name: 'Ramesh Kumar',
        phone: '9876543210',
      );

      expect(c.synced, false);
      expect(c.syncedAt, isNull);
    });

    test('name update on merge flags row for sync', () async {
      await seedCustomer(db);
      await (db.update(db.customers)..where((c) => c.id.equals('c1')))
          .write(const CustomersCompanion(synced: Value(true)));

      final updated = await repo.upsertByNameAndPhone(
        name: 'Ramesh K.',
        phone: '9876543210',
      );

      expect(updated.name, 'Ramesh K.');
      expect(updated.synced, false);
    });

    test('findByPhone finds merged customer', () async {
      await seedCustomer(db);
      final found = await repo.findByPhone('9876543210');
      expect(found?.id, 'c1');
      expect(await repo.findByPhone('9000000000'), isNull);
    });
  });
}
