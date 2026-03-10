import 'package:flutter/material.dart';
import 'package:minima/ui/theme/minima_theme.dart';

class HomeTopBar extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onSettingsTap;

  const HomeTopBar({super.key, required this.pendingCount, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: pendingCount > 0
                ? Text(
                    '$pendingCount pending',
                    key: ValueKey(pendingCount),
                    style: Theme.of(context).textTheme.labelMedium,
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: colors.textMuted, size: 22),
            onPressed: onSettingsTap,
          ),
        ],
      ),
    );
  }
}
