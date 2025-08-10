import 'package:core/core.dart';
import 'package:test/test.dart';

// no shared in-memory repos needed here

class InMemoryEntryRepository implements EntryRepository {
  final List<Entry> _entries = [];

  @override
  Future<void> save(Entry entry) async {
    _entries.add(entry);
  }

  @override
  Future<List<Entry>> listByDay(DateTime day) async {
    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    return _entries.where((e) => isSameDay(e.createdAt, day)).toList(growable: false);
  }
}

void main() {
  group('Entries flow', () {
    test('create and list by day', () async {
      final repo = InMemoryEntryRepository();
      final manager = EntryManager(entries: repo);

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      final e1 = await manager.create('First of today');
      final e2 = await manager.create('Second of today');

      // Simulate an entry yesterday by direct insert (only for test)
      final eY = Entry(id: UniqueId.newId(), content: 'Yesterday', createdAt: yesterday);
      await repo.save(eY);

      final todayList = await manager.listByDay(today);
      final yesterdayList = await manager.listByDay(yesterday);

      expect(todayList.map((e) => e.content).toSet(), equals({e1.content, e2.content}));
      expect(yesterdayList.map((e) => e.content).toList(), equals(['Yesterday']));
    });
  });
}
