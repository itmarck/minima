import 'package:minima/domain/subtask.dart';
import 'package:minima/domain/sync_status.dart';

abstract class SubtaskRepository {
  Future<void> upsert(Subtask subtask);
  Future<void> upsertAll(List<Subtask> subtasks);
  Future<List<Subtask>> getAll();
  Future<List<Subtask>> getByTaskNotionPageId(String taskNotionPageId);
  Future<List<Subtask>> getByStatus(SyncStatus status);
  Future<void> markCompleted(String id);
}
