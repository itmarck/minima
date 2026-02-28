import 'package:minima/domain/package_info.dart';
import 'package:minima/domain/package_repository.dart';

class PackageManager {
  final PackageRepository _repository;
  List<PackageInfo> _cachedPackages = [];

  PackageManager({required PackageRepository repository})
      : _repository = repository;

  /// Loads all installed packages. Call once during initialization.
  Future<void> loadPackages() async {
    final packages = await _repository.getInstalledPackages();
    packages
        .sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    _cachedPackages = packages;
  }

  /// All installed packages, sorted alphabetically.
  List<PackageInfo> get allPackages => _cachedPackages;

  /// Filters packages whose label contains [query] (case-insensitive).
  /// Returns empty list if query is blank.
  List<PackageInfo> search(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return [];
    return _cachedPackages
        .where((p) => p.label.toLowerCase().contains(trimmed))
        .toList();
  }

  /// Launches the package identified by [packageName].
  Future<bool> launchPackage(String packageName) {
    return _repository.launchPackage(packageName);
  }
}
