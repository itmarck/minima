import 'dart:convert';

import 'package:core/application.dart';
import 'package:core/domain.dart';
import 'package:core/store.dart';
import 'package:test/test.dart';

class MemoryEventStore extends EventStore {
  final List<Event> events = [];

  @override
  Future<void> append(Event event, EntityType type) async {
    events.add(event);
  }

  @override
  Future<void> clear() async {
    events.clear();
  }

  @override
  Future<void> dispose() {
    throw UnimplementedError();
  }

  @override
  Future<Entity?> find(UniqueId entityId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getEventsForEntity(
    UniqueId entityId,
  ) async {
    final filteredEvents = events.where((event) {
      return event.entityId == entityId;
    }).toList();

    return filteredEvents.map((event) {
      return {
        'id': event.id.value,
        'name': event.name.slug,
        'entity_id': event.entityId.value,
        'created_at': event.ocurredOn.millisecond,
        'payload': jsonEncode(event.payload),
      };
    }).toList();
  }

  @override
  Future<void> initialize() {
    throw UnimplementedError();
  }

  @override
  Future<List<UniqueId>> loadIds(EntityType entityType) async {
    return events.map((event) {
      return event.entityId;
    }).toList();
  }

  @override
  Future<String> get location => throw UnimplementedError();
}

void main() {
  group('class Note', () {
    test('it should create a note', () async {
      final store = MemoryEventStore();
      final manager = NoteManager(store: store);

      final initialNotes = await manager.getNotes();
      expect(initialNotes.length, 0);
      await manager.createNote('This is a test note');
      final notes = await manager.getNotes();
      expect(notes.length, 1);
    });
  });
}
