import 'package:flutter/widgets.dart';

import 'packages/shelf/server.dart';
import 'packages/sqlite/sqlite.dart';

abstract class Specification {
  Future<void> initialize(Database database, Server server);
  PreferredSizeWidget? appBar(BuildContext context);
}
