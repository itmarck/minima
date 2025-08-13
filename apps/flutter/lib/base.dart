import 'package:flutter/widgets.dart';

import 'packages/display/display.dart';
import 'packages/shelf/server.dart';
import 'packages/sqlite/sqlite.dart';
import 'specification.dart';
import 'widgets/base/base.dart';

void runBase({
  required Specification specification,
  required Database database,
  required Server server,
}) async {
  await specification.initialize(database, server);
  await Display.initialize();

  runApp(
    Base(
      specification: specification,
      database: database,
    ),
  );
}
