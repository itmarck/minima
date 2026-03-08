import 'package:flutter/material.dart';
import 'package:minima/ui/theme/minima_theme.dart';

class HomeTopBar extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onSettingsTap;

  const HomeTopBar({super.key, required this.pendingCount, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (pendingCount > 0)
            Text(
              '$pendingCount pending',
              style: TextStyle(color: MinimaTheme.textMuted, fontSize: 13),
            )
          else
            const SizedBox.shrink(),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: MinimaTheme.textMuted, size: 22),
            onPressed: onSettingsTap,
          ),
        ],
      ),
    );
  }
}
