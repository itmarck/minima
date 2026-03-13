import 'package:flutter/material.dart';
import 'package:minima/domain/task_manager.dart';
import 'package:minima/ui/theme/minima_theme.dart';

/// Displays a list of task items with staggered entry animation.
class TaskList extends StatefulWidget {
  final List<TaskItem> items;
  final ValueChanged<TaskItem> onComplete;

  const TaskList({super.key, required this.items, required this.onComplete});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  static const _staggerDelay = Duration(milliseconds: 40);
  static const _itemDuration = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    final totalDuration = _itemDuration + _staggerDelay * (widget.items.length.clamp(0, 20));
    _staggerController = AnimationController(vsync: this, duration: totalDuration)..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = _staggerController.duration!.inMilliseconds;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.items.length, (index) {
          final startMs = _staggerDelay.inMilliseconds * index;
          final endMs = startMs + _itemDuration.inMilliseconds;
          final begin = (startMs / totalMs).clamp(0.0, 1.0);
          final end = (endMs / totalMs).clamp(0.0, 1.0);

          final animation = CurvedAnimation(
            parent: _staggerController,
            curve: Interval(begin, end, curve: Curves.easeOut),
          );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: _TaskTile(
                item: widget.items[index],
                onComplete: () => widget.onComplete(widget.items[index]),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TaskTile extends StatefulWidget {
  final TaskItem item;
  final VoidCallback onComplete;

  const _TaskTile({required this.item, required this.onComplete});

  @override
  State<_TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<_TaskTile> with SingleTickerProviderStateMixin {
  late AnimationController _completeController;
  late Animation<double> _fadeOut;
  late Animation<Offset> _slideOut;

  @override
  void initState() {
    super.initState();
    _completeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeOut = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _completeController, curve: Curves.easeIn));
    _slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.15, 0),
    ).animate(CurvedAnimation(parent: _completeController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _completeController.dispose();
    super.dispose();
  }

  void _handleComplete() {
    _completeController.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeOut,
      child: SlideTransition(
        position: _slideOut,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TaskCheckbox(isSubtask: widget.item.isSubtask, onTap: _handleComplete),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: textTheme.bodyMedium?.copyWith(
                        color: widget.item.isSubtask ? colors.textSecondary : colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCheckbox extends StatelessWidget {
  final bool isSubtask;
  final VoidCallback onTap;

  const _TaskCheckbox({required this.isSubtask, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSubtask ? colors.textMuted : colors.textSecondary,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
