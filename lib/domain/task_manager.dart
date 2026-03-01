import 'package:minima/domain/subtask_repository.dart';
import 'package:minima/domain/task_repository.dart';

/// Unified display model for tasks and subtasks shown at the same level.
class TaskItem {
  final String id;
  final String notionPageId;
  final String title;
  final String subtitle;
  final bool isSubtask;

  const TaskItem({
    required this.id,
    required this.notionPageId,
    required this.title,
    required this.subtitle,
    required this.isSubtask,
  });
}

class TaskManager {
  final TaskRepository _taskRepository;
  final SubtaskRepository _subtaskRepository;

  TaskManager({
    required TaskRepository taskRepository,
    required SubtaskRepository subtaskRepository,
  })  : _taskRepository = taskRepository,
        _subtaskRepository = subtaskRepository;

  /// Returns the most recently modified active items (tasks + subtasks merged),
  /// sorted by last remote modification descending.
  Future<List<TaskItem>> getActiveItems({int limit = 5}) async {
    final tasks = await _taskRepository.getAll();
    final subtasks = await _subtaskRepository.getAll();

    // Build lookup for parent task names.
    final taskNames = <String, String>{};
    for (final task in tasks) {
      taskNames[task.notionPageId] = task.title;
    }

    final items = <_SortableTaskItem>[];

    for (final task in tasks) {
      if (!task.completed) {
        final statusLabel = task.status.replaceAll('_', ' ');
        items.add(_SortableTaskItem(
          item: TaskItem(
            id: task.id.value,
            notionPageId: task.notionPageId,
            title: task.title,
            subtitle: statusLabel,
            isSubtask: false,
          ),
          lastModifiedRemote: task.lastModifiedRemote,
        ));
      }
    }

    for (final subtask in subtasks) {
      if (!subtask.completed) {
        final parentName = taskNames[subtask.taskNotionPageId] ?? '';
        items.add(_SortableTaskItem(
          item: TaskItem(
            id: subtask.id.value,
            notionPageId: subtask.notionPageId,
            title: subtask.title,
            subtitle: parentName,
            isSubtask: true,
          ),
          lastModifiedRemote: subtask.lastModifiedRemote,
        ));
      }
    }

    items.sort(
      (a, b) => b.lastModifiedRemote.compareTo(a.lastModifiedRemote),
    );

    return items.take(limit).map((e) => e.item).toList();
  }

  /// Total count of non-completed tasks + subtasks.
  Future<int> getPendingCount() async {
    final tasks = await _taskRepository.getAll();
    final subtasks = await _subtaskRepository.getAll();
    return tasks.where((t) => !t.completed).length +
        subtasks.where((s) => !s.completed).length;
  }

  /// Marks an item as completed locally.
  Future<void> markComplete(TaskItem item) async {
    if (item.isSubtask) {
      await _subtaskRepository.markCompleted(item.id);
    } else {
      await _taskRepository.markCompleted(item.id);
    }
  }
}

class _SortableTaskItem {
  final TaskItem item;
  final DateTime lastModifiedRemote;

  const _SortableTaskItem({
    required this.item,
    required this.lastModifiedRemote,
  });
}
