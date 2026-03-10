import 'package:flutter/material.dart';
import 'package:minima/domain/package_info.dart';
import 'package:minima/ui/theme/minima_theme.dart';

/// Displays up to 5 favorite apps with staggered fade-in animation.
class FavoriteApps extends StatefulWidget {
  static const _maxItems = 5;
  static const _itemHeight = 40.0;

  final List<PackageInfo> homePackages;
  final ValueChanged<String> onLaunch;
  final Alignment alignment;

  const FavoriteApps({
    super.key,
    required this.homePackages,
    required this.onLaunch,
    this.alignment = Alignment.centerLeft,
  });

  @override
  State<FavoriteApps> createState() => _FavoriteAppsState();
}

class _FavoriteAppsState extends State<FavoriteApps> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const _staggerDelay = Duration(milliseconds: 60);
  static const _itemDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    final count = widget.homePackages.length.clamp(0, FavoriteApps._maxItems);
    final totalDuration = _itemDuration + _staggerDelay * count;
    _controller = AnimationController(vsync: this, duration: totalDuration)..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totalMs = _controller.duration!.inMilliseconds;
    final items = widget.homePackages.take(FavoriteApps._maxItems).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.alignment == Alignment.centerRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        for (int index = 0; index < items.length; index++)
          _buildItem(items[index], index, totalMs, colors),
      ],
    );
  }

  Widget _buildItem(PackageInfo pkg, int index, int totalMs, MinimaColors colors) {
    const verticalPadding = 8.0;
    const horizontalPadding = 16.0;

    final startMs = _staggerDelay.inMilliseconds * index;
    final endMs = startMs + _itemDuration.inMilliseconds;
    final begin = (startMs / totalMs).clamp(0.0, 1.0);
    final end = (endMs / totalMs).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: animation,
      child: SizedBox(
        height: FavoriteApps._itemHeight,
        child: Align(
          alignment: widget.alignment,
          child: GestureDetector(
            onTap: () => widget.onLaunch(pkg.packageName),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(
                left: widget.alignment == Alignment.centerRight ? horizontalPadding : 0,
                right: widget.alignment == Alignment.centerRight ? 0 : horizontalPadding,
                bottom: verticalPadding,
                top: verticalPadding,
              ),
              child: Text(
                pkg.label,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
