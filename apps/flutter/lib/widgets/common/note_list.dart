import 'package:flutter/material.dart';
import 'package:core/core.dart';

class NoteList extends StatelessWidget {
  final List<Note> notes;
  final void Function(Note) onTap;

  const NoteList({super.key, required this.notes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (notes.isEmpty) {
      return Center(
        child: Text('No hay notas', style: TextStyle(color: scheme.onSurfaceVariant)),
      );
    }

    return ListView.separated(
      itemCount: notes.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final n = notes[index];
        return ListTile(
          title: Text(n.content, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text('${n.createdAt.toLocal()}'),
          onTap: () => onTap(n),
        );
      },
    );
  }
}

