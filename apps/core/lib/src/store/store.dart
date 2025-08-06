import 'package:core/domain.dart';

abstract class EventStore {
  Future<void> initialize();
  Future<void> dispose();
  Future<void> clear();

  Future<String> get location;

  Future<Entity?> find(UniqueId entityId);
  Future<List<Map<String, dynamic>>> getEventsForEntity(UniqueId entityId);
  Future<List<UniqueId>> loadIds(EntityType type);
  Future<void> append(Event event, EntityType type);
}

abstract class Snapshot {}
