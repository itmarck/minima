import 'package:flutter/material.dart';
import 'package:minima/domain/task_manager.dart';
import 'package:minima/ui/widgets/drag_handle.dart';
import 'package:minima/ui/widgets/task_list.dart';

void showTaskBottomSheet(
  BuildContext context, {
  required List<TaskItem> items,
  required ValueChanged<TaskItem> onComplete,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
    builder: (context) => _TaskBottomSheetContent(items: items, onComplete: onComplete),
  );
}

class _TaskBottomSheetContent extends StatelessWidget {
  final List<TaskItem> items;
  final ValueChanged<TaskItem> onComplete;

  const _TaskBottomSheetContent({required this.items, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(padding: EdgeInsets.only(top: 12, bottom: 16), child: DragHandle()),
        if (items.isEmpty)
          Expanded(
            child: Center(child: Text('No pending tasks', style: textTheme.bodySmall)),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: TaskList(items: items, onComplete: onComplete),
            ),
          ),
      ],
    );
  }
}
