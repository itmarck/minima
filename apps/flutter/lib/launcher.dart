import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:minima/packages/shelf/server.dart';

import 'shell.dart';

void main() async {
  runShell(
    onInit: () async {
      await initializeBackgroundService();
    },
  );
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
