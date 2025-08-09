import 'package:test/test.dart';

import 'package:core/src/notes/notes.dart';
import 'package:core/src/shared/unique_id.dart';
import 'infrastructure/repositories.dart';

void main() {
  group('Notes flow', () {
    test('create and fetch a note', () async {
      final notes = InMemoryNoteRepository();
      final manager = NoteManager(notes: notes);

      const content = 'Research: read clean architecture paper.';
      final created = await manager.create(content);

      expect(created.id.value, isNotEmpty);
      expect(created.content, equals(content));

      final fetched = await manager.get(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.id, equals(created.id));
      expect(fetched.content, equals(content));
    });

    test('search notes by text', () async {
      final notes = InMemoryNoteRepository();
      final manager = NoteManager(notes: notes);

      final n1 = await manager.create('Research: read clean architecture paper.');
      final n2 = await manager.create('Write summary and next actions');

      final result1 = await notes.searchByText('clean');
      expect(result1.map((n) => n.id).toSet(), equals({n1.id}));

      final result2 = await notes.searchByText('summary');
      expect(result2.map((n) => n.id).toSet(), equals({n2.id}));

      final result3 = await notes.searchByText('unknown');
      expect(result3, isEmpty);
    });

    test('getById returns null when not present', () async {
      final notes = InMemoryNoteRepository();
      final missing = await notes.getById(UniqueId.newId());
      expect(missing, isNull);
    });
  });
}
