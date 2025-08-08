import 'package:core/application.dart';
import 'package:core/domain.dart';
import 'package:core/store.dart';
import 'package:test/test.dart';

class InMemoryEventStore implements EventStore {
  final Map<String, List<Event>> _events = {};

  @override
  Future<void> append(Event event) async {
    if (!_events.containsKey(event.entityId.value)) {
      _events[event.entityId.value] = [];
    }

    final lastVersion = _events[event.entityId.value]!.length;
    if (event.version != lastVersion + 1) {
      throw Exception(
        'Event version mismatch. Expected ${lastVersion + 1}, got ${event.version}',
      );
    }

    _events[event.entityId.value]!.add(event);
  }

  @override
  Future<void> appendAll(List<Event> events) async {
    for (final event in events) {
      await append(event);
    }
  }

  @override
  Future<List<Event>> getEventsForEntity(UniqueId entityId) async {
    if (!_events.containsKey(entityId.value)) {
      return Future.value([]);
    }

    return Future.value(List.of(_events[entityId.value]!));
  }
}

void main() {
  group('class Note', () {
    test('it should create a note', () async {
      final store = InMemoryEventStore();
      final manager = NoteManager(store: store);

      await manager.createNote('This is a test note');
    });
  });
}
