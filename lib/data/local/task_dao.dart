import 'package:minima/data/local/database.dart';
import 'package:minima/domain/sync_status.dart';
import 'package:minima/domain/task.dart';
import 'package:minima/domain/task_repository.dart';
import 'package:minima/domain/unique_id.dart';
import 'package:sqflite/sqflite.dart';

class TaskDao implements TaskRepository {
  final AppDatabase _database;

  TaskDao(this._database);

  @override
  Future<void> upsert(Task task) async {
    await _database.db.insert(
      'tasks',
      _toRow(task),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> upsertAll(List<Task> tasks) async {
    final batch = _database.db.batch();
    for (final task in tasks) {
      batch.insert(
        'tasks',
        _toRow(task),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Task>> getAll() async {
    final rows = await _database.db.query('tasks');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<Task>> getByStatus(SyncStatus status) async {
    final rows = await _database.db.query(
      'tasks',
      where: 'sync_status = ?',
      whereArgs: [status.name],
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> markCompleted(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.db.update(
      'tasks',
      {
        'completed': 1,
        'last_modified_local': now,
        'sync_status': SyncStatus.pending.name,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, Object?> _toRow(Task task) {
    return {
      'id': task.id.value,
      'notion_page_id': task.notionPageId,
      'title': task.title,
      'status': task.status,
      'completed': task.completed ? 1 : 0,
      'last_modified_remote': task.lastModifiedRemote.millisecondsSinceEpoch,
      'last_modified_local':
          task.lastModifiedLocal?.millisecondsSinceEpoch,
      'sync_status': task.syncStatus.name,
    };
  }

  Task _fromRow(Map<String, Object?> row) {
    return Task(
      id: UniqueId(row['id'] as String),
      notionPageId: row['notion_page_id'] as String,
      title: row['title'] as String,
      status: row['status'] as String? ?? 'pending',
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
