import 'package:flutter/material.dart';

class NoteInputBar extends StatefulWidget {
  final Future<void> Function(String content) onSubmit;
  final VoidCallback onSwipeUp;

  const NoteInputBar({super.key, required this.onSubmit, required this.onSwipeUp});

  @override
  State<NoteInputBar> createState() => _NoteInputBarState();
}

class _NoteInputBarState extends State<NoteInputBar> {
  final _controller = TextEditingController();
  bool _sheetOpened = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta != null && details.primaryDelta! < -8 && !_sheetOpened) {
          _sheetOpened = true;
          widget.onSwipeUp();
          Future.delayed(const Duration(milliseconds: 500), () => _sheetOpened = false);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: 'Escribe una nota...', border: InputBorder.none),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: _submit, child: const Text('Agregar')),
          ],
        ),
      ),
    );
  }
}

