import 'package:minima/data/local/database.dart';
import 'package:minima/domain/package_preference.dart';
import 'package:minima/domain/package_preference_repository.dart';

class PackagePreferenceDao implements PackagePreferenceRepository {
  final AppDatabase _database;

  PackagePreferenceDao(this._database);

  @override
  Future<List<PackagePreference>> getAll() async {
    final rows = await _database.db.query('package_preferences');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<PackagePreference>> getHomePackages() async {
    final rows = await _database.db.query(
      'package_preferences',
      where: 'is_home = 1',
      orderBy: 'home_order ASC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> setHome(String packageName, bool isHome) async {
    if (isHome) {
      // Compute next order.
      final result = await _database.db.rawQuery(
        'SELECT COALESCE(MAX(home_order), -1) + 1 AS next_order '
        'FROM package_preferences WHERE is_home = 1',
      );
      final nextOrder = result.first['next_order'] as int;

      await _database.db.rawInsert(
        'INSERT INTO package_preferences (package_name, is_home, is_hidden, home_order) '
        'VALUES (?, 1, 0, ?) '
        'ON CONFLICT(package_name) DO UPDATE SET is_home = 1, home_order = ?',
        [packageName, nextOrder, nextOrder],
      );
    } else {
      await _database.db.rawUpdate(
        'UPDATE package_preferences SET is_home = 0, home_order = 0 '
        'WHERE package_name = ?',
        [packageName],
      );
    }
  }

  @override
  Future<void> setHidden(String packageName, bool isHidden) async {
    final hiddenInt = isHidden ? 1 : 0;

    await _database.db.rawInsert(
      'INSERT INTO package_preferences (package_name, is_home, is_hidden, home_order) '
      'VALUES (?, 0, ?, 0) '
      'ON CONFLICT(package_name) DO UPDATE SET is_hidden = ?',
      [packageName, hiddenInt, hiddenInt],
    );
  }

  PackagePreference _fromRow(Map<String, Object?> row) {
    return PackagePreference(
      packageName: row['package_name'] as String,
      isHome: (row['is_home'] as int) == 1,
      isHidden: (row['is_hidden'] as int) == 1,
      homeOrder: row['home_order'] as int,
    );
  }
}
