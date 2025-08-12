import 'dart:io';

import 'package:flutter/material.dart';
import 'package:minima/configuration.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class Desktop extends StatefulWidget {
  final Widget child;

  const Desktop({super.key, required this.child});

  @override
  State<Desktop> createState() => _DesktopState();

  static Future<void> initialize() async {
    // Initialize window manager for desktop
    await windowManager.ensureInitialized();
    await windowManager.setPreventClose(true);

    WindowOptions windowOptions = WindowOptions(
      size: Size(360, 640),
      minimumSize: Size(240, 480),
      title: Configuration.appName,
      center: true,
      titleBarStyle: TitleBarStyle.hidden,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // Initialize system tray
    final icon = Platform.isWindows ? 'minima.ico' : 'minima.png';
    await trayManager.setIcon('assets/images/$icon');
    await trayManager.setToolTip('Minima v0.1.0');
  }
}

class _DesktopState extends State<Desktop> with WindowListener, TrayListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    trayManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await windowManager.hide();
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    //
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
