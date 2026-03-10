import 'package:flutter/material.dart';

/// Shows a confirmation dialog with Cancel/Confirm buttons.
/// Returns `true` if the user confirmed, `false` otherwise.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Confirm', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ),
      ],
    ),
  );
  return result ?? false;
}
