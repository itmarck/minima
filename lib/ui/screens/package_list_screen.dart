import 'package:flutter/material.dart';
import 'package:minima/domain/package_info.dart';
import 'package:minima/domain/package_manager.dart';
import 'package:minima/ui/theme/minima_theme.dart';
import 'package:minima/ui/widgets/package_tile.dart';

class PackageListScreen extends StatefulWidget {
  final PackageManager packageManager;

  const PackageListScreen({super.key, required this.packageManager});

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  List<PackageInfo> _visiblePackages = [];
  List<PackageInfo> _hiddenPackages = [];

  @override
  void initState() {
    super.initState();
    _refreshLists();
  }

  void _refreshLists() {
    setState(() {
      _visiblePackages = widget.packageManager.visiblePackages;
      _hiddenPackages = widget.packageManager.hiddenPackages;
    });
  }

  void _showContextMenu(PackageInfo package) {
    final isHome = widget.packageManager.isHome(package.packageName);
    final isHidden = widget.packageManager.isHidden(package.packageName);

    final options = <(String, String)>[];

    if (isHome) {
      options.add(('remove_home', 'Remove from home'));
    } else {
      options.add(('add_home', 'Add to home'));
    }

    if (isHome && widget.packageManager.canMoveUp(package.packageName)) {
      options.add(('move_up', 'Move up'));
    }

    if (isHome && widget.packageManager.canMoveDown(package.packageName)) {
      options.add(('move_down', 'Move down'));
    }

    if (isHidden) {
      options.add(('show', 'Show'));
    } else {
      options.add(('hide', 'Hide'));
    }

    options.add(('uninstall', 'Uninstall'));

    showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(package.label),
        children: [
          for (final (value, label) in options)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, value),
              child: Text(label),
            ),
        ],
      ),
    ).then((value) async {
      if (value == null) return;

      switch (value) {
        case 'add_home':
        case 'remove_home':
          await widget.packageManager.toggleHome(package.packageName);
        case 'hide':
        case 'show':
          await widget.packageManager.toggleHidden(package.packageName);
        case 'move_up':
          await widget.packageManager.moveUp(package.packageName);
        case 'move_down':
          await widget.packageManager.moveDown(package.packageName);
        case 'uninstall':
          await widget.packageManager.uninstallPackage(package.packageName);
      }

      _refreshLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totalCount = _visiblePackages.length + (_hiddenPackages.isNotEmpty ? 1 : 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Apps')),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: totalCount,
        itemBuilder: (context, index) {
          if (index < _visiblePackages.length) {
            final package = _visiblePackages[index];
            return PackageTile(
              label: package.label,
              isHome: widget.packageManager.isHome(package.packageName),
              onTap: () => widget.packageManager.launchPackage(package.packageName),
              onLongPress: () => _showContextMenu(package),
            );
          }

          // Hidden apps accordion.
          return ExpansionTile(
            title: Text(
              'Hidden apps (${_hiddenPackages.length})',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.textMuted),
            ),
            iconColor: colors.textMuted,
            collapsedIconColor: colors.textMuted,
            children: _hiddenPackages.map((package) {
              return PackageTile(
                label: package.label,
                isHome: widget.packageManager.isHome(package.packageName),
                isMuted: true,
                onTap: () => widget.packageManager.launchPackage(package.packageName),
                onLongPress: () => _showContextMenu(package),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
