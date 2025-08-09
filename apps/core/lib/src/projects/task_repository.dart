import '../shared/unique_id.dart';
import 'task.dart';

abstract class TaskRepository {
  Future<void> save(Task task);
  Future<Task?> getById(UniqueId id);
  Future<List<Task>> findByJobId(UniqueId jobId);
}

