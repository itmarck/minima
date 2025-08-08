import 'package:core/domain.dart';

abstract class EventStore {
  /// Add a single event to the store.
  Future<void> append(Event event);

  /// Add a list of events to the store.
  Future<void> appendAll(List<Event> events);

  /// Returns all events for an specific entity order by its
  /// version number.
  Future<List<Event>> getEventsForEntity(UniqueId entityId);
}
