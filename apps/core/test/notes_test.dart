import 'package:core/core.dart';
import 'package:test/test.dart';

import 'infrastructure/repositories.dart';

void main() {
  group('Notes', () {
    test('create and fetch a note', () async {
      final manager = NoteManager(notes: InMemoryNoteRepository());

      const content = 'test a note';
      final createdNote = await manager.create(content);

      expect(createdNote.id.value, isNotEmpty);
      expect(createdNote.content, equals(content));

      final note = await manager.get(createdNote.id);
      expect(note, isNotNull);
      expect(note!.id, equals(createdNote.id));
    });

    test('search notes by text', () async {
      final manager = NoteManager(notes: InMemoryNoteRepository());

      await manager.create('Research: read clean architecture paper.');
      await manager.create('Write summary and next actions');

      final result1 = await manager.searchByText('clean');
      expect(result1.length, equals(1));

      final result2 = await manager.searchByText('summary');
      expect(result2.length, equals(1));

      final result3 = await manager.searchByText('unknown');
      expect(result3, isEmpty);
    });

    test('return null if the note does not exist', () async {
      final manager = NoteManager(notes: InMemoryNoteRepository());
      final missing = await manager.get(UniqueId.newId());
      expect(missing, isNull);
    });
  });
}
