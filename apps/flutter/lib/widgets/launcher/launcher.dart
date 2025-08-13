import 'package:flutter/widgets.dart';
import 'package:minima/packages/background/background.dart';
import 'package:minima/packages/shelf/server.dart';
import 'package:minima/packages/sqlite/sqlite.dart';
import 'package:minima/specification.dart';

class LauncherSpecification extends Specification {
  @override
  Future<void> initialize(Database database, Server server) async {
    await Background.initializeService();
  }

  @override
  PreferredSizeWidget? appBar(BuildContext context) => null;
}
