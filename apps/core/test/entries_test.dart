import 'package:core/core.dart';
import 'package:test/test.dart';

import 'infrastructure/repositories.dart';

void main() {
  group('Entries', () {
    test('create and list by day', () async {
      final repository = InMemoryEntryRepository();
      final manager = EntryManager(entries: repository);

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      await manager.create('first of today');
      await manager.create('second of today');

      // Simulate an entry yesterday by direct insert (only for test)
      await repository.save(
        Entry(id: UniqueId.newId(), content: 'yesterday entry', createdAt: yesterday),
      );

      final todayList = await manager.listByDay(today);
      expect(todayList.length, equals(2));

      final yesterdayList = await manager.listByDay(yesterday);
      expect(yesterdayList.length, equals(1));
    });
  });
}
