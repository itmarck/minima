import 'package:flutter/services.dart';
import 'package:sqlite3/sqlite3.dart';

const _migrationsDirectory = 'assets/sql';

const Map<int, String> _migrations = {
  1: '001_initial_schema.sql',
  // 2: '002_update_schema.sql',
};

Future<void> migrate(Database db, {Map<int, String> migrations = _migrations}) async {
  final currentVersion = db.select('PRAGMA user_version;').first.values.first as int;
  final sortedMigrations = migrations.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  final maxVersion = sortedMigrations.isNotEmpty ? sortedMigrations.last.key : currentVersion;
  final pendingMigrations = sortedMigrations.where((m) => m.key > currentVersion).toList();

  if (currentVersion > maxVersion) {
    throw Exception('The code only supports up to version $maxVersion. Downgrade not allowed.');
  }

  if (pendingMigrations.isEmpty) {
    return;
  }

  db.execute('BEGIN;');

  try {
    for (final entry in pendingMigrations) {
      final version = entry.key;
      final path = '$_migrationsDirectory/${entry.value}';
      final sql = await rootBundle.loadString(path);

      print('Aplicando migración $version desde $path...');
      db.execute(sql);
      db.execute('PRAGMA user_version = $version;');
    }
    db.execute('COMMIT;');
    print('Migraciones completadas.');
  } catch (e) {
    db.execute('ROLLBACK;');
    rethrow;
  }
}
