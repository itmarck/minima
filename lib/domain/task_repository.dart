import 'package:minima/domain/sync_status.dart';
import 'package:minima/domain/task.dart';

abstract class TaskRepository {
  Future<void> upsert(Task task);
  Future<void> upsertAll(List<Task> tasks);
  Future<List<Task>> getAll();
  Future<List<Task>> getByStatus(SyncStatus status);
  Future<void> markCompleted(String id);
}
