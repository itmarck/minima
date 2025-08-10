import 'package:flutter/services.dart';

import 'package.dart';

/// Manages the installed packages.
class Bundle {
  static const MethodChannel _channel = MethodChannel('packages');

  Future<List<Package>> getInstalledPackages() async {
    try {
      final List result = await _channel.invokeMethod('getInstalledPackages');

      return result
          .cast<Map<dynamic, dynamic>>()
          .map((map) => Package.fromJson(Map<String, dynamic>.from(map)))
          .toList();
    } on PlatformException {
      return [];
    }
  }

  Future<bool> launch(String name) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('launch', {'name': name});
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
