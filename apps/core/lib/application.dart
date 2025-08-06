import 'package:core/core.dart';
import 'package:core/domain.dart';
import 'package:core/services.dart';
import 'package:core/store.dart';

class NetworkManager {
  NetworkService _network;

  NetworkManager({required NetworkService network}) : _network = network;

  Future<List<Node>> getNodes() async {
    return await _network.getNodes();
  }
}

class NoteManager {
  final EventStore _store;

  NoteManager({required EventStore store}) : _store = store;

  Future<void> createNote(String content) async {
    final change = Note.create(content);
    await _store.append(change.event, change.entity);
  }

  Future<List<Note?>> getNotes() async {
    final entityIds = await _store.loadIds(EntityType.note.name);

    return await Future.wait(
      entityIds.map((id) => get(id)).toList(),
    );
  }

  Future<Note?> get(UniqueId id) async {
    final eventRecords = await _store.getEventsForEntity(id);

    if (eventRecords.isEmpty) {
      return null;
    }

    final deserializers = {
      EventName.noteCreated: NoteCreated.from,
    };

    final List<Event> events = eventRecords.map((records) {
      final name = records['name'] as String;
      final eventName = name.toEventName();
      final deserializer = deserializers[eventName];

      if (deserializer == null) {
        throw Exception('Unknown event type: $name');
      }

      return deserializer(records);
    }).toList();

    if (events.first is! NoteCreated) {
      return null;
    }

    Note note = Note.fromEvent(events.first as NoteCreated);

    for (int index = 1; index < events.length; index++) {
      note = note.apply(events[index]);
    }

    return note;
  }
}

abstract class EntityFinder {
  static const Set<EntityType> allowedEntities = {
    EntityType.project,
    EntityType.job,
    EntityType.task,
  };

  Future<List<Entity>> findEntitiesByQuery(String query);
}

class ReferenceResolver {
  final EntityFinder _finder;

  ReferenceResolver(this._finder);

  /// Provides suggestions to the UI as the user types after an '@' sign.
  Future<List<Entity>> getSuggestions(String query) async {
    return await _finder.findEntitiesByQuery(query);
  }

  Reference? resolveReference(Entity entity) {
    if (entity.displayName == null) {
      return null;
    }

    return Reference(
      entityType: EntityType.project,
      source: entity.id,
      content: entity.displayName,
    );
  }
}
