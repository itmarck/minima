import 'package:flutter_background_service/flutter_background_service.dart';

import 'base.dart';
import 'packages/shelf/server.dart';

void main() async {
  runBase(
    onInit: () async {
      // await initializeBackgroundService();
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
