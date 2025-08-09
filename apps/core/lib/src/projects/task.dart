import '../shared/entity.dart';
import '../shared/unique_id.dart';

class Task extends Entity {
  final UniqueId jobId;
  final String title;
  final bool done;

  const Task({
    required super.id,
    required this.jobId,
    required this.title,
    this.done = false,
    super.references = const [],
  });

  Task toggle() => Task(
        id: id,
        jobId: jobId,
        title: title,
        done: !done,
        references: references,
      );
}

