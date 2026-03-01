import 'package:flutter/material.dart';
import 'package:minima/domain/package_info.dart';
import 'package:minima/domain/package_manager.dart';
import 'package:minima/ui/theme/minima_theme.dart';

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

  void _showContextMenu(
    BuildContext context,
    Offset position,
    PackageInfo package,
  ) {
    final isHome = widget.packageManager.isHome(package.packageName);
    final isHidden = widget.packageManager.isHidden(package.packageName);

    final items = <PopupMenuEntry<String>>[];

    if (isHome) {
      items.add(const PopupMenuItem(
        value: 'remove_home',
        child: Text('Remove from home'),
      ));
    } else {
      items.add(const PopupMenuItem(
        value: 'add_home',
        child: Text('Add to home'),
      ));
    }

    if (isHidden) {
      items.add(const PopupMenuItem(
        value: 'show',
        child: Text('Show'),
      ));
    } else {
      items.add(const PopupMenuItem(
        value: 'hide',
        child: Text('Hide'),
      ));
    }

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
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
    final totalCount =
        _visiblePackages.length + (_hiddenPackages.isNotEmpty ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Apps',
          style: TextStyle(color: MinimaTheme.textPrimary, fontSize: 18),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: totalCount,
        itemBuilder: (context, index) {
          if (index < _visiblePackages.length) {
            return _buildPackageTile(_visiblePackages[index]);
          }

          // Hidden apps accordion.
          return _buildHiddenSection();
        },
      ),
    );
  }

  Widget _buildPackageTile(PackageInfo package) {
    final isHome = widget.packageManager.isHome(package.packageName);

    return GestureDetector(
      onLongPressStart: (details) =>
          _showContextMenu(context, details.globalPosition, package),
      child: ListTile(
        title: Text(
          package.label,
          style: TextStyle(
            color: MinimaTheme.textPrimary,
            fontSize: 14,
          ),
        ),
        trailing: isHome
            ? Icon(
                Icons.home_outlined,
                color: MinimaTheme.textMuted,
                size: 16,
              )
            : null,
        onTap: () =>
            widget.packageManager.launchPackage(package.packageName),
      ),
    );
  }

  Widget _buildHiddenSection() {
    return ExpansionTile(
      title: Text(
        'Hidden apps (${_hiddenPackages.length})',
        style: TextStyle(
          color: MinimaTheme.textMuted,
          fontSize: 14,
        ),
      ),
      iconColor: MinimaTheme.textMuted,
      collapsedIconColor: MinimaTheme.textMuted,
      children: _hiddenPackages.map((package) {
        final isHome = widget.packageManager.isHome(package.packageName);

        return GestureDetector(
          onLongPressStart: (details) =>
              _showContextMenu(context, details.globalPosition, package),
          child: ListTile(
            title: Text(
              package.label,
              style: TextStyle(
                color: MinimaTheme.textMuted,
                fontSize: 14,
              ),
            ),
            trailing: isHome
                ? Icon(
                    Icons.home_outlined,
                    color: MinimaTheme.textMuted,
                    size: 16,
                  )
                : null,
            onTap: () =>
                widget.packageManager.launchPackage(package.packageName),
          ),
        );
      }).toList(),
    );
  }
}
