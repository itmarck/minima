import 'package:minima/data/local/database.dart';
import 'package:minima/domain/subtask.dart';
import 'package:minima/domain/subtask_repository.dart';
import 'package:minima/domain/sync_status.dart';
import 'package:minima/domain/unique_id.dart';
import 'package:sqflite/sqflite.dart';

class SubtaskDao implements SubtaskRepository {
  final AppDatabase _database;

  SubtaskDao(this._database);

  @override
  Future<void> upsert(Subtask subtask) async {
    await _database.db.insert(
      'subtasks',
      _toRow(subtask),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> upsertAll(List<Subtask> subtasks) async {
    final batch = _database.db.batch();
    for (final subtask in subtasks) {
      batch.insert(
        'subtasks',
        _toRow(subtask),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Subtask>> getAll() async {
    final rows = await _database.db.query('subtasks');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<Subtask>> getByTaskNotionPageId(
    String taskNotionPageId,
  ) async {
    final rows = await _database.db.query(
      'subtasks',
      where: 'task_notion_page_id = ?',
      whereArgs: [taskNotionPageId],
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<Subtask>> getByStatus(SyncStatus status) async {
    final rows = await _database.db.query(
      'subtasks',
      where: 'sync_status = ?',
      whereArgs: [status.name],
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> markCompleted(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.db.update(
      'subtasks',
      {
        'completed': 1,
        'last_modified_local': now,
        'sync_status': SyncStatus.pending.name,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, Object?> _toRow(Subtask subtask) {
    return {
      'id': subtask.id.value,
      'notion_page_id': subtask.notionPageId,
      'task_notion_page_id': subtask.taskNotionPageId,
      'title': subtask.title,
      'completed': subtask.completed ? 1 : 0,
      'last_modified_remote':
          subtask.lastModifiedRemote.millisecondsSinceEpoch,
      'last_modified_local':
          subtask.lastModifiedLocal?.millisecondsSinceEpoch,
      'sync_status': subtask.syncStatus.name,
    };
  }

  Subtask _fromRow(Map<String, Object?> row) {
    return Subtask(
      id: UniqueId(row['id'] as String),
      notionPageId: row['notion_page_id'] as String,
      taskNotionPageId: row['task_notion_page_id'] as String,
      title: row['title'] as String,
      completed: (row['completed'] as int) == 1,
      lastModifiedRemote: DateTime.fromMillisecondsSinceEpoch(
        row['last_modified_remote'] as int,
      ),
      lastModifiedLocal: row['last_modified_local'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              row['last_modified_local'] as int,
            )
          : null,
      syncStatus: SyncStatus.values.byName(row['sync_status'] as String),
    );
  }
}
