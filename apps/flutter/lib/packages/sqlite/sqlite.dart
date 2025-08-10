import 'package:minima/configuration.dart';
import 'package:minima/packages/sqlite/migrate.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

export 'repositories.dart';
export 'package:sqlite3/sqlite3.dart';

class Sqlite {
  static Future<Database> initialize() async {
    final dir = await getApplicationSupportDirectory();
    final path = join(dir.path, Configuration.databaseName);
    final database = sqlite3.open(path);

    await migrate(database);

    return database;
  }
}
