import 'package:core/core.dart';
import 'package:sqlite3/sqlite3.dart';

class SqliteProjectRepository implements ProjectRepository {
  final Database _db;
  SqliteProjectRepository(Database db) : _db = db;

  @override
  Future<Project?> getById(UniqueId id) async {
    final row = _db.select(
      '''
      SELECT key, value FROM records
      WHERE entity_kind = ? AND entity_id = ?
      ORDER BY created_at DESC
      ''',
      ['project', id.value],
    );
    if (row.isEmpty) return null;

    final latest = <String, String>{};
    for (final r in row) {
      final k = r['key'] as String;
      if (!latest.containsKey(k)) latest[k] = r['value'] as String;
    }

    return Project(
      id: id,
      title: latest['title'] ?? '',
      description: latest['description'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(int.tryParse(latest['createdAt'] ?? '') ?? 0),
    );
  }

  @override
  Future<void> save(Project project) async {
    final eventId = UniqueId.newId().value;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    _db.execute('INSERT INTO events(id, entity_kind, entity_id, occurred_at) VALUES(?, ?, ?, ?)', [
      eventId,
      'project',
      project.id.value,
      nowMs,
    ]);

    void insert(String key, String value) {
      _db.execute(
        'INSERT INTO records(id, event_id, entity_kind, entity_id, key, value, created_at) VALUES(?, ?, ?, ?, ?, ?, ?)',
        [UniqueId.newId().value, eventId, 'project', project.id.value, key, value, nowMs],
      );
    }

    insert('title', project.title);
    insert('description', project.description);
    insert('createdAt', project.createdAt.millisecondsSinceEpoch.toString());
  }

  @override
  Future<List<Project>> searchByText(String query) async {
    final q = '%${query.toLowerCase()}%';
    final result = _db.select(
      '''
      WITH latest AS (
        SELECT entity_id, value AS title, created_at,
               ROW_NUMBER() OVER (PARTITION BY entity_id ORDER BY created_at DESC) AS rn
        FROM records WHERE entity_kind = 'project' AND key = 'title'
      )
      SELECT entity_id FROM latest WHERE rn = 1 AND LOWER(title) LIKE ?
      ''',
      [q],
    );

    final items = <Project>[];
    for (final row in result) {
      final id = UniqueId.fromString(row['entity_id'] as String);
      final p = await getById(id);
      if (p != null) items.add(p);
    }
    return items;
  }
}
