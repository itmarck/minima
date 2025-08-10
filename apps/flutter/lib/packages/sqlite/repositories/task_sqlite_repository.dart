import 'package:core/core.dart';

class SqliteTaskRepository extends TaskRepository {
  @override
  Future<List<Task>> findByJobId(UniqueId jobId) {
    throw UnimplementedError();
  }

  @override
  Future<Task?> getById(UniqueId id) {
    throw UnimplementedError();
  }

  @override
  Future<void> save(Task task) {
    throw UnimplementedError();
  }
}
