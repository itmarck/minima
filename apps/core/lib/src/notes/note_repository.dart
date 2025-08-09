import '../shared/unique_id.dart';
import 'note.dart';

abstract class NoteRepository {
  Future<void> save(Note note);
  Future<Note?> getById(UniqueId id);
  Future<List<Note>> searchByText(String query);
}

