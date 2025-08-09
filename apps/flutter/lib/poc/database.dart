import 'package:sqlite3/sqlite3.dart';

class AppDatabase {
  static Database? _db;

  static Database get db => _db ??= _openAndInit();

  static Database _openAndInit() {
    final database = sqlite3.openInMemory();

    database.execute('PRAGMA foreign_keys = ON;');

    database.execute('''
      CREATE TABLE IF NOT EXISTS events (
        id TEXT PRIMARY KEY,
        entity_kind TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        occurred_at INTEGER NOT NULL
      );
    ''');

    database.execute('''
      CREATE TABLE IF NOT EXISTS records (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        entity_kind TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
      );
    ''');

    database.execute('''
      CREATE INDEX IF NOT EXISTS idx_records_entity_key_time
      ON records(entity_kind, entity_id, key, created_at);
    ''');

    database.execute('''
      CREATE INDEX IF NOT EXISTS idx_records_kind_key_time
      ON records(entity_kind, key, created_at);
    ''');

    return database;
  }
}
