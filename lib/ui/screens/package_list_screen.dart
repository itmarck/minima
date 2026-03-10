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

  void _showContextMenu(Offset position, PackageInfo package) {
    final isHome = widget.packageManager.isHome(package.packageName);
    final isHidden = widget.packageManager.isHidden(package.packageName);

    final items = <PopupMenuEntry<String>>[];

    if (isHome) {
      items.add(const PopupMenuItem(value: 'remove_home', child: Text('Remove from home')));
    } else {
      items.add(const PopupMenuItem(value: 'add_home', child: Text('Add to home')));
    }

    if (isHidden) {
      items.add(const PopupMenuItem(value: 'show', child: Text('Show')));
    } else {
      items.add(const PopupMenuItem(value: 'hide', child: Text('Hide')));
    }

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: items,
    ).then((value) async {
      if (value == null) return;

      switch (value) {
        case 'add_home':
        case 'remove_home':
          await widget.packageManager.toggleHome(package.packageName);
        case 'hide':
        case 'show':
          await widget.packageManager.toggleHidden(package.packageName);
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
              onLongPress: (position) => _showContextMenu(position, package),
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
                onLongPress: (position) => _showContextMenu(position, package),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
