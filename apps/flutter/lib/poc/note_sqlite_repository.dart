import 'dart:convert';

import 'package:core/core.dart';
import 'package:sqlite3/sqlite3.dart';

import 'database.dart';

class SqliteNoteRepository implements NoteRepository {
  final Database _db;

  SqliteNoteRepository([Database? db]) : _db = db ?? AppDatabase.db;

  @override
  Future<Note?> getById(UniqueId id) async {
    final row = _db.select(
      '''
      SELECT key, value FROM records
      WHERE entity_kind = ? AND entity_id = ?
      ORDER BY created_at DESC
      ''',
      ['note', id.value],
    );

    if (row.isEmpty) return null;

    // pick latest value for each property
    final latest = <String, String>{};
    for (final r in row) {
      final k = r['key'] as String;
      if (!latest.containsKey(k)) {
        latest[k] = r['value'] as String;
      }
    }

    final content = latest['content'] ?? '';
    final createdAtMs = int.tryParse(latest['createdAt'] ?? '') ?? 0;
    final createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtMs);
    final references = _decodeReferences(latest['references']);

    return Note(
      id: id,
      content: content,
      createdAt: createdAt,
      references: references,
    );
  }

  @override
  Future<void> save(Note note) async {
    final eventId = UniqueId.newId().value;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    _db.execute(
      'INSERT INTO events(id, entity_kind, entity_id, occurred_at) VALUES(?, ?, ?, ?)',
      [eventId, 'note', note.id.value, nowMs],
    );

    void insertRecord(String key, String value) {
      _db.execute(
        'INSERT INTO records(id, event_id, entity_kind, entity_id, key, value, created_at) VALUES(?, ?, ?, ?, ?, ?, ?)',
        [
          UniqueId.newId().value,
          eventId,
          'note',
          note.id.value,
          key,
          value,
          nowMs,
        ],
      );
    }

    insertRecord('content', note.content);
    insertRecord('createdAt', note.createdAt.millisecondsSinceEpoch.toString());
    insertRecord(
      'references',
      jsonEncode(note.references.map(_refToJson).toList()),
    );
  }

  @override
  Future<List<Note>> searchByText(String query) async {
    final q = '%${query.toLowerCase()}%';
    // get latest content per entity_id by created_at using window function
    final result = _db.select(
      '''
      WITH latest AS (
        SELECT entity_id, value AS content, created_at,
               ROW_NUMBER() OVER (PARTITION BY entity_id ORDER BY created_at DESC) AS rn
        FROM records WHERE entity_kind = 'note' AND key = 'content'
      )
      SELECT entity_id FROM latest WHERE rn = 1 AND LOWER(content) LIKE ?
      ''',
      [q],
    );

    final notes = <Note>[];
    for (final row in result) {
      final id = UniqueId.fromString(row['entity_id'] as String);
      final n = await getById(id);
      if (n != null) notes.add(n);
    }
    return notes;
  }

  List<Reference> _decodeReferences(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((m) {
      return Reference(
        id: UniqueId.fromString(m['id'] as String),
        kind: EntityKind.values.firstWhere(
          (e) => e.name == (m['kind'] as String),
        ),
        description: m['description'] as String,
      );
    }).toList();
  }

  Map<String, dynamic> _refToJson(Reference r) => {
    'id': r.id.value,
    'kind': r.kind.name,
    'description': r.description,
  };
}
