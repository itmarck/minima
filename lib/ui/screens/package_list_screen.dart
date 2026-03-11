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

class _PackageListScreenState extends State<PackageListScreen>
    with WidgetsBindingObserver {
  List<PackageInfo> _visiblePackages = [];
  List<PackageInfo> _hiddenPackages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshLists();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reloadPackages();
    }
  }

  Future<void> _reloadPackages() async {
    await widget.packageManager.loadPackages();
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
    final canMoveUp = isHome && widget.packageManager.canMoveUp(package.packageName);
    final canMoveDown = isHome && widget.packageManager.canMoveDown(package.packageName);

    showDialog<String>(
      context: context,
      builder: (context) {
        final colors = context.colors;

        return Dialog(
          child: Container(
            width: 120,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(package.label, style: Theme.of(context).dialogTheme.titleTextStyle),
                ),
                const SizedBox(height: 12),
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, isHome ? 'remove_home' : 'add_home'),
                  child: Text(isHome ? 'Remove from home' : 'Add to home'),
                ),
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, isHidden ? 'show' : 'hide'),
                  child: Text(isHidden ? 'Show' : 'Hide'),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (canMoveUp)
                        IconButton(
                          icon: Icon(Icons.arrow_upward, color: colors.textSecondary, size: 20),
                          onPressed: () => Navigator.pop(context, 'move_up'),
                        ),
                      if (canMoveDown)
                        IconButton(
                          icon: Icon(Icons.arrow_downward, color: colors.textSecondary, size: 20),
                          onPressed: () => Navigator.pop(context, 'move_down'),
                        ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: colors.textSecondary, size: 20),
                        onPressed: () => Navigator.pop(context, 'uninstall'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
