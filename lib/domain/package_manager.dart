import 'package:minima/domain/package_info.dart';
import 'package:minima/domain/package_preference.dart';
import 'package:minima/domain/package_preference_repository.dart';
import 'package:minima/domain/package_repository.dart';

class PackageManager {
  final PackageRepository _repository;
  final PackagePreferenceRepository? _preferenceRepository;

  List<PackageInfo> _cachedPackages = [];
  Map<String, PackagePreference> _preferenceMap = {};

  PackageManager({
    required PackageRepository repository,
    PackagePreferenceRepository? preferenceRepository,
  })  : _repository = repository,
        _preferenceRepository = preferenceRepository;

  /// Loads all installed packages. Call once during initialization.
  Future<void> loadPackages() async {
    final packages = await _repository.getInstalledPackages();
    packages.sort(
      (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
    );
    _cachedPackages = packages;
  }

  /// Loads all preferences from SQLite. Call after loadPackages().
  Future<void> loadPreferences() async {
    final prefs = await _preferenceRepository?.getAll() ?? [];
    _preferenceMap = {for (final p in prefs) p.packageName: p};
  }

  /// All installed packages, sorted alphabetically.
  List<PackageInfo> get allPackages => _cachedPackages;

  /// Packages not marked as hidden, sorted alphabetically.
  List<PackageInfo> get visiblePackages {
    return _cachedPackages
        .where((p) => !isHidden(p.packageName))
        .toList();
  }

  /// Packages marked as hidden, sorted alphabetically.
  List<PackageInfo> get hiddenPackages {
    return _cachedPackages
        .where((p) => isHidden(p.packageName))
        .toList();
  }

  /// Packages marked as home, ordered by homeOrder.
  List<PackageInfo> get homePackages {
    final homePrefs = _preferenceMap.values
        .where((p) => p.isHome)
        .toList()
      ..sort((a, b) => a.homeOrder.compareTo(b.homeOrder));

    final packageMap = {for (final p in _cachedPackages) p.packageName: p};

    return homePrefs
        .where((p) => packageMap.containsKey(p.packageName))
        .map((p) => packageMap[p.packageName]!)
        .toList();
  }

  bool isHome(String packageName) =>
      _preferenceMap[packageName]?.isHome ?? false;

  bool isHidden(String packageName) =>
      _preferenceMap[packageName]?.isHidden ?? false;

  /// Toggles whether a package appears on the home screen.
  Future<void> toggleHome(String packageName) async {
    final current = isHome(packageName);
    await _preferenceRepository?.setHome(packageName, !current);
    await loadPreferences();
  }

  /// Toggles whether a package is hidden from the app list.
  Future<void> toggleHidden(String packageName) async {
    final current = isHidden(packageName);
    await _preferenceRepository?.setHidden(packageName, !current);
    await loadPreferences();
  }

  /// Filters packages whose label contains [query] (case-insensitive).
  /// Returns empty list if query is blank. Searches all packages.
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
