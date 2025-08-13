import 'dart:io';

import 'package:flutter/widgets.dart';

import 'base.dart';
import 'packages/shelf/shelf.dart';
import 'packages/sqlite/sqlite.dart';
import 'widgets/desktop/desktop.dart';
import 'widgets/launcher/launcher.dart';

final platforms = {
  'android': LauncherSpecification(),
  'windows': DesktopSpecification(),
  'linux': DesktopSpecification(),
};

void main() async {
  final system = Platform.operatingSystem;
  final specification = platforms[system];

  if (specification == null) {
    throw Exception('Unsupported platform: ${system}');
  }

  WidgetsFlutterBinding.ensureInitialized();

  final database = await Sqlite.instance;
  final server = Shelf.server;

  runBase(
    database: database,
    server: server,
    specification: specification,
  );
}
