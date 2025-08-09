import '../shared/reference.dart';
import '../shared/unique_id.dart';
import 'note.dart';
import 'note_repository.dart';

class NoteManager {
  final NoteRepository _notes;

  NoteManager({required NoteRepository notes}) : _notes = notes;

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

