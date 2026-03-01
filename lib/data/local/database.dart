import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _name = 'minima.db';
  static const _version = 3;

  final Database db;

  AppDatabase._(this.db);

  static Future<AppDatabase> open() async {
    final path = p.join(await getDatabasesPath(), _name);
    final db = await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return AppDatabase._(db);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE drafts (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        notion_page_id TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        notion_page_id TEXT NOT NULL UNIQUE,
        title TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        completed INTEGER NOT NULL DEFAULT 0,
        last_modified_remote INTEGER NOT NULL,
        last_modified_local INTEGER,
        sync_status TEXT NOT NULL DEFAULT 'synced'
      )
    ''');

    await db.execute('''
      CREATE TABLE subtasks (
        id TEXT PRIMARY KEY,
        notion_page_id TEXT NOT NULL UNIQUE,
        task_notion_page_id TEXT NOT NULL,
        title TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        last_modified_remote INTEGER NOT NULL,
        last_modified_local INTEGER,
        sync_status TEXT NOT NULL DEFAULT 'synced'
      )
    ''');

    await db.execute('''
      CREATE TABLE package_preferences (
        package_name TEXT PRIMARY KEY,
        is_home INTEGER NOT NULL DEFAULT 0,
        is_hidden INTEGER NOT NULL DEFAULT 0,
        home_order INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE tasks ADD COLUMN status TEXT NOT NULL DEFAULT 'pending'",
      );
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE package_preferences (
          package_name TEXT PRIMARY KEY,
          is_home INTEGER NOT NULL DEFAULT 0,
          is_hidden INTEGER NOT NULL DEFAULT 0,
          home_order INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
  }

  Future<void> close() => db.close();
}
