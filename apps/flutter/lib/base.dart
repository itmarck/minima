import 'package:flutter/widgets.dart';

import 'packages/display/display.dart';
import 'packages/sqlite/sqlite.dart';
import 'widgets/base/base.dart';

void runBase({
  Widget? home,
  void Function()? onInit,
  void Function()? onReady,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (onInit != null) {
    onInit();
  }

  await Display.initialize();
  final database = await Sqlite.initialize();

  if (onReady != null) {
    onReady();
  }

  runApp(
    Base(
      database: database,
      home: home,
    ),
  );
}
