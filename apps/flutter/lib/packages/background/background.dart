import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:minima/packages/shelf/shelf.dart';

class Background {
  static Future<void> initializeService() async {
    await FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: true,
        isForegroundMode: true,
        autoStartOnBoot: false,
      ),
      iosConfiguration: IosConfiguration(),
    );
    await FlutterBackgroundService().startService();
  }
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  final server = Shelf.server;
  await server.start();
}
