import 'reference.dart';
import 'unique_id.dart';

/// Base class for all domain entities.
/// Entities are identified by a UniqueId and contain a list of References
/// that represent both implicit and calculated references.
abstract class Entity {
  final UniqueId id;
  final DateTime createdAt;
  final List<Reference> references;

  const Entity({
    required this.id,
    required this.createdAt,
    this.references = const [],
  });
}

