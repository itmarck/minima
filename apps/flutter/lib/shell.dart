import 'package:flutter/material.dart';
import 'package:minima/packages/display/display.dart';
import 'package:minima/packages/themes/themes.dart';
import 'package:minima/ui/sizes.dart';

abstract class Slots {
  Widget get home;
}

class Shell extends StatelessWidget {
  final Slots? slots;

  const Shell({super.key, this.slots});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: blackTheme.themeData,
      home: Scaffold(
        body: SafeArea(
          child: Display(
            child: Column(
              children: [
                Expanded(
                  child: Text(''),
                ),
                BottomInbox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomInbox extends StatefulWidget {
  const BottomInbox({super.key});

  @override
  State<BottomInbox> createState() => _BottomInboxState();
}

class _BottomInboxState extends State<BottomInbox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.horizontalScreen,
        vertical: Sizes.verticalScreen,
      ),
      child: Text('Input'),
    );
  }
}
