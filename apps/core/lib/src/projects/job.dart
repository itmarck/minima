import '../shared/entity.dart';
import '../shared/unique_id.dart';

class Job extends Entity {
  final UniqueId projectId;
  final String title;

  const Job({
    required super.id,
    required this.projectId,
    required this.title,
    super.references = const [],
  });
}

