import 'package:flutter/material.dart';
import 'package:minima/domain/task_manager.dart';
import 'package:minima/ui/theme/minima_theme.dart';

class TaskList extends StatelessWidget {
  final List<TaskItem> items;
  final ValueChanged<TaskItem> onComplete;

  const TaskList({super.key, required this.items, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => onComplete(item),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2, right: 12),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: item.isSubtask
                              ? MinimaTheme.textMuted
                              : MinimaTheme.textSecondary,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: item.isSubtask
                              ? MinimaTheme.textSecondary
                              : MinimaTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            color: MinimaTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
