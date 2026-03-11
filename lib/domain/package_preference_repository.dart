import 'package:minima/domain/package_preference.dart';

abstract class PackagePreferenceRepository {
  Future<List<PackagePreference>> getAll();
  Future<List<PackagePreference>> getHomePackages();
  Future<void> setHome(String packageName, bool isHome);
  Future<void> setHidden(String packageName, bool isHidden);
  Future<void> swapHomeOrder(String packageNameA, String packageNameB);
}
