import 'package:flutter/material.dart';
import 'package:minima/domain/package_manager.dart';
import 'package:minima/ui/theme/minima_theme.dart';

class PackageListScreen extends StatelessWidget {
  final PackageManager packageManager;

  const PackageListScreen({super.key, required this.packageManager});

  @override
  Widget build(BuildContext context) {
    final packages = packageManager.allPackages;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Apps',
          style: TextStyle(color: MinimaTheme.textPrimary, fontSize: 18),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final package = packages[index];
          return ListTile(
            title: Text(
              package.label,
              style: const TextStyle(
                color: MinimaTheme.textPrimary,
                fontSize: 14,
              ),
            ),
            onTap: () => packageManager.launchPackage(package.packageName),
          );
        },
      ),
    );
  }
}
