import 'package:flutter/material.dart';
import 'package:minima/domain/actionable.dart';
import 'package:minima/ui/theme/minima_theme.dart';

class ActionableResults extends StatelessWidget {
  static const maxResults = 3;
  static const _tileHeight = 48.0;
  static const _bottomMargin = 8.0;
  static const totalHeight =
      _tileHeight * maxResults + _bottomMargin;

  final List<Actionable> results;
  final void Function(Actionable actionable) onTap;

  const ActionableResults({
    super.key,
    required this.results,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: totalHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (results.isNotEmpty)
            Container(
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
            ),
          if (results.isNotEmpty) const SizedBox(height: _bottomMargin),
        ],
      ),
    );
  }
}

String _subtitleForType(ActionableType type) {
  switch (type) {
    case ActionableType.package:
      return 'Application';
  }
}

IconData _iconForType(ActionableType type) {
  switch (type) {
    case ActionableType.package:
      return Icons.layers;
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
      child: SizedBox(
        height: ActionableResults._tileHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                _iconForType(actionable.type),
                color: MinimaTheme.textMuted,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      actionable.label,
                      style: TextStyle(
                        color: MinimaTheme.textPrimary,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitleForType(actionable.type),
                      style: TextStyle(
                        color: MinimaTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
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
