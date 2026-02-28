import 'package:minima/data/local/database.dart';
import 'package:minima/domain/draft.dart';
import 'package:minima/domain/draft_repository.dart';
import 'package:minima/domain/sync_status.dart';
import 'package:minima/domain/unique_id.dart';

class DraftDao implements DraftRepository {
  final AppDatabase _database;

  DraftDao(this._database);

  @override
  Future<void> save(Draft draft) async {
    await _database.db.insert('drafts', {
      'id': draft.id.value,
      'title': draft.title,
      'created_at': draft.createdAt.millisecondsSinceEpoch,
      'notion_page_id': draft.notionPageId,
      'sync_status': draft.syncStatus.name,
    });
  }

  @override
  Future<List<Draft>> getAll() async {
    final rows = await _database.db.query('drafts', orderBy: 'created_at DESC');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<Draft>> getByStatus(SyncStatus status) async {
    final rows = await _database.db.query(
      'drafts',
      where: 'sync_status = ?',
      whereArgs: [status.name],
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> updateSyncStatus(
    String id,
    SyncStatus status,
    String notionPageId,
  ) async {
    await _database.db.update(
      'drafts',
      {'sync_status': status.name, 'notion_page_id': notionPageId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Draft _fromRow(Map<String, Object?> row) {
    return Draft(
      id: UniqueId(row['id'] as String),
      title: row['title'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      notionPageId: row['notion_page_id'] as String?,
      syncStatus: SyncStatus.values.byName(row['sync_status'] as String),
    );
  }
}
