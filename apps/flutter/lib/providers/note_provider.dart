import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:core/core.dart';

class NoteProvider extends ChangeNotifier {
  final NoteManager _manager;

  NoteProvider({required NoteRepository notes}) : _manager = NoteManager(notes: notes);

  List<Note> _items = const [];
  List<Note> get items => _items;

  Future<void> load({String query = ''}) async {
    _items = await _manager.searchByText(query);
    notifyListeners();
  }

  Future<void> addNote(String content) async {
    await _manager.create(content);
    await load();
  }

  static NoteProvider of(BuildContext context) {
    return Provider.of<NoteProvider>(context, listen: false);
  }
}
