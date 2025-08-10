import '../core/entity.dart';
import '../core/unique_id.dart';

class Job extends Entity {
  final UniqueId projectId;
  final String title;

  const Job({
    required super.id,
    required this.projectId,
    required this.title,
    required super.createdAt,
    super.references = const [],
  });
}

