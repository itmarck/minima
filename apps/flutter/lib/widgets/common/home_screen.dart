import 'package:flutter/material.dart';
import 'package:minima/providers/providers.dart';

import 'note_input_bar.dart';
import 'note_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      NoteProvider.of(context).load();
    });
  }

  Future<void> _onAddNote(String content) async {
    await NoteProvider.of(context).addNote(content);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Consumer<NoteProvider>(
            builder: (context, provider, child) {
              return NoteList(
                notes: provider.items,
                onTap: (_) {},
              );
            },
          ),
        ),
        NoteInputBar(onSubmit: _onAddNote, onSwipeUp: () {}),
      ],
    );
  }
}
