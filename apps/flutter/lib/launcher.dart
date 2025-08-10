import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:minima/packages/shelf/server.dart';

import 'poc/bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeBackgroundService();
  runApp(await buildApp());

  Future.delayed(Duration(seconds: 3), () async {});
}

Future<void> initializeBackgroundService() async {
  await FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      autoStartOnBoot: false,
    ),
    iosConfiguration: IosConfiguration(),
  );
  await FlutterBackgroundService().startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final server = Server();
  await server.start();
}
