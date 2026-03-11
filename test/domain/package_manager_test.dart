import 'package:flutter_test/flutter_test.dart';
import 'package:minima/domain/package_info.dart';
import 'package:minima/domain/package_manager.dart';
import 'package:minima/domain/package_repository.dart';

class InMemoryPackageRepository implements PackageRepository {
  final List<PackageInfo> _packages;
  final List<String> launchedPackages = [];

  InMemoryPackageRepository(this._packages);

  @override
  Future<List<PackageInfo>> getInstalledPackages() async =>
      List.of(_packages);

  @override
  Future<bool> launchPackage(String packageName) async {
    launchedPackages.add(packageName);
    return true;
  }

  @override
  Future<bool> uninstallPackage(String packageName) async {
    return true;
  }
}

void main() {
  late InMemoryPackageRepository repository;
  late PackageManager manager;

  setUp(() async {
    repository = InMemoryPackageRepository([
      const PackageInfo(packageName: 'com.app.zebra', label: 'Zebra'),
      const PackageInfo(packageName: 'com.app.alpha', label: 'Alpha'),
      const PackageInfo(packageName: 'com.app.middle', label: 'Middle'),
    ]);
    manager = PackageManager(repository: repository);
    await manager.loadPackages();
  });

  test('allPackages returns packages sorted alphabetically', () {
    final labels = manager.allPackages.map((p) => p.label).toList();
    expect(labels, ['Alpha', 'Middle', 'Zebra']);
  });

  test('search returns matching packages case-insensitively', () {
    final results = manager.search('alp');
    expect(results, hasLength(1));
    expect(results.first.label, 'Alpha');
  });

  test('search returns empty list for empty query', () {
    expect(manager.search(''), isEmpty);
    expect(manager.search('   '), isEmpty);
  });

  test('search returns empty list for no matches', () {
    expect(manager.search('xyz'), isEmpty);
  });

  test('launchPackage delegates to repository', () async {
    await manager.launchPackage('com.app.alpha');
    expect(repository.launchedPackages, ['com.app.alpha']);
  });
}
