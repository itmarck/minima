import '../core/unique_id.dart';
import 'entry.dart';
import 'entry_repository.dart';

class EntryManager {
  final EntryRepository _entries;

  EntryManager({required EntryRepository entries}) : _entries = entries;

  Future<Entry> create(String content) async {
    final entry = Entry(id: UniqueId.newId(), content: content, createdAt: DateTime.now());
    await _entries.save(entry);
    return entry;
  }

  Future<List<Entry>> listByDay(DateTime day) async {
    return _entries.listByDay(day);
  }
}

