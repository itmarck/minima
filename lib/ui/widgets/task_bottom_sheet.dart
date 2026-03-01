import 'package:flutter/material.dart';
import 'package:minima/domain/task_manager.dart';
import 'package:minima/ui/theme/minima_theme.dart';
import 'package:minima/ui/widgets/task_list.dart';

void showTaskBottomSheet(
  BuildContext context, {
  required List<TaskItem> items,
  required ValueChanged<TaskItem> onComplete,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: MinimaTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.7,
    ),
    builder: (context) => _TaskBottomSheetContent(
      items: items,
      onComplete: onComplete,
    ),
  );
}

class _TaskBottomSheetContent extends StatelessWidget {
  final List<TaskItem> items;
  final ValueChanged<TaskItem> onComplete;

  const _TaskBottomSheetContent({
    required this.items,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle.
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: MinimaTheme.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        if (items.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'No pending tasks',
                style: TextStyle(color: MinimaTheme.textMuted),
              ),
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: TaskList(
                items: items,
                onComplete: onComplete,
              ),
            ),
          ),
      ],
    );
  }
}
