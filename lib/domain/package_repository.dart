import 'package:minima/domain/package_info.dart';

/// Provides access to installed packages on the device.
/// Returns an empty list on platforms that do not support package listing.
abstract class PackageRepository {
  Future<List<PackageInfo>> getInstalledPackages();
  Future<bool> launchPackage(String packageName);
}
