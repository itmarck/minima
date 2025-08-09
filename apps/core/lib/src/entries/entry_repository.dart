import 'entry.dart';

abstract class EntryRepository {
  Future<void> save(Entry entry);
  Future<List<Entry>> listByDay(DateTime day);
}

