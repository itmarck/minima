import 'dart:io';

import 'package:flutter/services.dart';
import 'package:minima/domain/package_info.dart';
import 'package:minima/domain/package_repository.dart';

class PlatformPackageRepository implements PackageRepository {
  static const _channel = MethodChannel('com.itmarck.minima/packages');

  @override
  Future<List<PackageInfo>> getInstalledPackages() async {
    if (!Platform.isAndroid) return [];

    try {
      final List<dynamic> result =
          await _channel.invokeMethod('getInstalledPackages');
      return result.map((item) {
        final map = item as Map<dynamic, dynamic>;
        return PackageInfo(
          packageName: map['packageName'] as String,
          label: map['label'] as String,
          icon: map['icon'] as Uint8List?,
        );
      }).toList();
    } on PlatformException {
      return [];
    }
  }

  @override
  Future<bool> launchPackage(String packageName) async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>(
        'launchPackage',
        {'packageName': packageName},
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
