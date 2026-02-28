import 'package:flutter/material.dart';
import 'package:minima/domain/actionable.dart';
import 'package:minima/ui/theme/minima_theme.dart';

class ActionableResults extends StatelessWidget {
  final List<Actionable> results;
  final void Function(Actionable actionable) onTap;

  const ActionableResults({
    super.key,
    required this.results,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: MinimaTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final actionable in results)
            _ActionableTile(
              actionable: actionable,
              onTap: () => onTap(actionable),
            ),
        ],
      ),
    );
  }
}

class _ActionableTile extends StatelessWidget {
  final Actionable actionable;
  final VoidCallback onTap;

  const _ActionableTile({required this.actionable, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(
              Icons.open_in_new,
              color: MinimaTheme.textMuted,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                actionable.label,
                style: const TextStyle(
                  color: MinimaTheme.textPrimary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
