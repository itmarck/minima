import 'package:flutter/services.dart';

class Wallpaper {
  static const platform = MethodChannel('wallpaper');

  static Future<void> setWallpaper() async {
    await platform.invokeMethod('setWallpaper');
  }
}
