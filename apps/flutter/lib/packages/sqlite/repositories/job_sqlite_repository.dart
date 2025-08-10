import 'dart:convert';

import 'package:core/core.dart';
import 'package:sqlite3/sqlite3.dart';

class SqliteJobRepository implements JobRepository {
  final Database _db;
  SqliteJobRepository(Database db) : _db = db;

  @override
  Future<Job?> getById(UniqueId id) async {
    final rows = _db.select(
      '''
      SELECT key, value FROM records
      WHERE entity_kind = ? AND entity_id = ?
      ORDER BY created_at DESC
      ''',
      ['job', id.value],
    );
    if (rows.isEmpty) return null;

    final latest = <String, String>{};
    for (final r in rows) {
      final k = r['key'] as String;
      if (!latest.containsKey(k)) latest[k] = r['value'] as String;
    }

    final projectId = UniqueId.fromString(latest['projectId'] ?? '');
    final title = latest['title'] ?? '';
    final createdAtMs = int.tryParse(latest['createdAt'] ?? '') ?? 0;
    final createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtMs);
    final references = _decodeReferences(latest['references']);

    return Job(
      id: id,
      projectId: projectId,
      title: title,
      createdAt: createdAt,
      references: references,
    );
  }

  @override
  Future<void> save(Job job) async {
    final eventId = UniqueId.newId().value;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    _db.execute('INSERT INTO events(id, entity_kind, entity_id, occurred_at) VALUES(?, ?, ?, ?)', [
      eventId,
      'job',
      job.id.value,
      nowMs,
    ]);

    void insertRecord(String key, String value) {
      _db.execute(
        'INSERT INTO records(id, event_id, entity_kind, entity_id, key, value, created_at) VALUES(?, ?, ?, ?, ?, ?, ?)',
        [UniqueId.newId().value, eventId, 'job', job.id.value, key, value, nowMs],
      );
    }

    insertRecord('projectId', job.projectId.value);
    insertRecord('title', job.title);
    insertRecord('createdAt', job.createdAt.millisecondsSinceEpoch.toString());
    insertRecord('references', jsonEncode(job.references.map(_refToJson).toList()));
  }

  @override
  Future<List<Job>> findByProjectId(UniqueId projectId) async {
    final result = _db.select(
      '''
      WITH latest AS (
        SELECT entity_id, key, value, created_at,
               ROW_NUMBER() OVER (PARTITION BY entity_id, key ORDER BY created_at DESC) AS rn
        FROM records WHERE entity_kind = 'job'
      )
      SELECT entity_id FROM latest
      WHERE rn = 1 AND key = 'projectId' AND value = ?
      ''',
      [projectId.value],
    );

    final jobs = <Job>[];
    for (final row in result) {
      final id = UniqueId.fromString(row['entity_id'] as String);
      final j = await getById(id);
      if (j != null) jobs.add(j);
    }
    // Newest first
    jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return jobs;
  }
}

Map<String, dynamic> _refToJson(Reference r) => {
      'id': r.id.value,
      'kind': r.kind.name,
    };

List<Reference> _decodeReferences(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  return list
      .map((m) => Reference(
            id: UniqueId.fromString(m['id'] as String),
            kind: EntityKind.values.firstWhere((e) => e.name == (m['kind'] as String)),
          ))
      .toList(growable: false);
}

