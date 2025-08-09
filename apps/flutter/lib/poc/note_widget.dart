import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'note_provider.dart';

class NoteWidget extends StatefulWidget {
  const NoteWidget({super.key});

  @override
  State<NoteWidget> createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // No async gaps before using context
    final model = context.read<NoteModel>();
    model.load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: 'Write a note...'),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: _submit, child: const Text('Add')),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Consumer<NoteModel>(
            builder: (context, model, _) {
              if (model.items.isEmpty) {
                return const Center(child: Text('No notes'));
              }
              return ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: 8),
                  ...model.items.map(
                    (n) => Container(
                      width: 260,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.content, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(
                            n.id.value,
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          Text(
                            '${n.createdAt.toLocal()}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await context.read<NoteModel>().addNote(text);
    _controller.clear();
  }
}
