import 'package:flutter/material.dart';
import 'package:minima/ui/theme/minima_theme.dart';

class HomeTopBar extends StatefulWidget {
  final int pendingCount;
  final bool isSyncing;
  final VoidCallback onSettingsTap;

  const HomeTopBar({
    super.key,
    required this.pendingCount,
    required this.onSettingsTap,
    this.isSyncing = false,
  });

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends State<HomeTopBar> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isSyncing) _rotationController.repeat();
  }

  @override
  void didUpdateWidget(HomeTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSyncing && !oldWidget.isSyncing) {
      _rotationController.repeat();
    } else if (!widget.isSyncing && oldWidget.isSyncing) {
      _rotationController.stop();
      _rotationController.reset();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 20, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: widget.pendingCount > 0
                ? Text(
                    '${widget.pendingCount} pending',
                    key: ValueKey(widget.pendingCount),
                    style: Theme.of(context).textTheme.labelMedium,
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: widget.isSyncing
                    ? Padding(
                        key: const ValueKey('syncing'),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: RotationTransition(
                          turns: _rotationController,
                          child: Icon(
                            Icons.sync,
                            color: colors.textMuted,
                            size: 20,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('idle')),
              ),
              IconButton(
                icon: Icon(Icons.settings_outlined, color: colors.textMuted, size: 22),
                onPressed: widget.onSettingsTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
