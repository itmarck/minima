import 'package:flutter/material.dart';
import 'package:minima/domain/draft.dart';
import 'package:minima/domain/sync_status.dart';
import 'package:minima/ui/theme/minima_theme.dart';

/// Shows a modal bottom sheet with recent drafts.
void showDraftsModal(BuildContext context, {required List<Draft> drafts}) {
  showModalBottomSheet(
    context: context,
    builder: (context) => _DraftsModalContent(drafts: drafts),
  );
}

class _DraftsModalContent extends StatelessWidget {
  final List<Draft> drafts;

  const _DraftsModalContent({required this.drafts});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    if (drafts.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(child: Text('No recent drafts', style: textTheme.bodySmall)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: drafts.length,
      itemBuilder: (context, index) {
        final draft = drafts[index];
        final isSynced = draft.syncStatus == SyncStatus.synced;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedOpacity(
            opacity: isSynced ? 0.4 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Row(
              children: [
                Icon(
                  isSynced ? Icons.check_circle_outline : Icons.schedule,
                  color: colors.textMuted,
                  size: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    draft.title,
                    style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
