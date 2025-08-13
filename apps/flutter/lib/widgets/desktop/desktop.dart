import 'package:flutter/material.dart';
import 'package:minima/packages/shelf/server.dart';
import 'package:minima/packages/sqlite/sqlite.dart';
import 'package:minima/specification.dart';

import 'bar.dart';

class DesktopSpecification extends Specification {
  @override
  Future<void> initialize(Database database, Server server) async {
    await server.start();
  }

  @override
  PreferredSizeWidget? appBar(context) {
    return const Bar();
  }
}
