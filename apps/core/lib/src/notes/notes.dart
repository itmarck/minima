import '../shared/entity.dart';
import '../shared/reference.dart';
import '../shared/unique_id.dart';

class Note extends Entity {
  final String content;

  const Note({
    required super.id,
    required this.content,
    super.references = const [],
  });

  Note copyWith({String? content, List<Reference>? references}) => Note(
        id: id,
        content: content ?? this.content,
        references: references ?? this.references,
      );
}

abstract class NoteRepository {
  Future<void> save(Note note);
  Future<Note?> getById(UniqueId id);
  Future<List<Note>> searchByText(String query);
}

class InMemoryNoteRepository implements NoteRepository {
  final Map<String, Note> _store = {};

  @override
  Future<Note?> getById(UniqueId id) async => _store[id.value];

  @override
  Future<void> save(Note note) async {
    _store[note.id.value] = note;
  }

  @override
  Future<List<Note>> searchByText(String query) async {
    final q = query.toLowerCase();
    return _store.values
        .where((n) => n.content.toLowerCase().contains(q))
        .toList(growable: false);
  }
}

class NoteManager {
  final NoteRepository _notes;

  NoteManager({required NoteRepository notes}) : _notes = notes;

  Future<Note> create(String content, {List<Reference> references = const []}) async {
    final note = Note(id: UniqueId.newId(), content: content, references: references);
    await _notes.save(note);
    return note;
  }

  Future<Note?> get(UniqueId id) => _notes.getById(id);
}

