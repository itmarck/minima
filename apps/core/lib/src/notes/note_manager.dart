import '../core/reference.dart';
import '../core/unique_id.dart';
import 'note.dart';
import 'note_repository.dart';

class NoteManager {
  final NoteRepository _notes;

  NoteManager({required NoteRepository notes}) : _notes = notes;

  Future<List<Note>> searchByText(String query) async {
    return await _notes.searchByText(query);
  }

  Future<Note> create(String content, {List<Reference> references = const []}) async {
    final note = Note(
      id: UniqueId.newId(),
      content: content,
      createdAt: DateTime.now(),
      references: references,
    );
    await _notes.save(note);
    return note;
  }

  Future<Note?> get(UniqueId id) => _notes.getById(id);
}
