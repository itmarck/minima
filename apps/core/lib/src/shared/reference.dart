import 'unique_id.dart';

/// The set of domain entity kinds supported by the core package.
enum EntityKind { note, project, job, task }

/// Value Object representing a lightweight reference to an entity.
/// Holds enough information to display a reference without extra lookups.
class Reference {
  final UniqueId id;
  final EntityKind kind;
  final String? description;

  const Reference({required this.id, required this.kind, this.description});

  @override
  String toString() => '[${kind.name}] $description (${id.value})';
}
