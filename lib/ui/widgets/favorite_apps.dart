import 'package:flutter/material.dart';
import 'package:minima/domain/package_info.dart';
import 'package:minima/ui/theme/minima_theme.dart';

class FavoriteApps extends StatelessWidget {
  static const maxSlots = 5;
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: _itemHeight * maxSlots,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: alignment == Alignment.centerRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: List.generate(maxSlots, (index) {
          if (index < homePackages.length) {
            final pkg = homePackages[index];
            final verticalPadding = 8.0;
            final horizontalPadding = 16.0;

            return SizedBox(
              height: _itemHeight,
              child: Align(
                alignment: alignment,
                child: GestureDetector(
                  onTap: () => onLaunch(pkg.packageName),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: alignment == Alignment.centerRight
                          ? horizontalPadding
                          : 0,
                      right: alignment == Alignment.centerRight
                          ? 0
                          : horizontalPadding,
                      bottom: verticalPadding,
                      top: verticalPadding,
                    ),
                    child: Text(
                      pkg.label,
                      style: TextStyle(
                        color: MinimaTheme.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return SizedBox(height: _itemHeight);
        }),
      ),
    );
  }
}
