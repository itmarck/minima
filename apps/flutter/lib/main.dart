import 'package:flutter/material.dart';
import 'package:minima/packages/display/display.dart';
import 'package:minima/shell.dart';

class DesktopSlots extends Slots {
  @override
  Widget get home {
    return const Text('Text from Windows');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Display.initialize();

  runApp(
    Shell(slots: DesktopSlots()),
  );
}
