import 'package:flutter/widgets.dart';

import 'packages/display/display.dart';
import 'packages/sqlite/sqlite.dart';
import 'specification.dart';
import 'widgets/base/base.dart';

void runBase({
  required Specification specification,
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
      specification: specification,
      database: database,
    ),
  );
}
