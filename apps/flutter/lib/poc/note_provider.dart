import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:core/core.dart';

class NoteModel extends ChangeNotifier {
  final NoteRepository _repository;

  NoteModel(this._repository);

  List<Note> _items = const [];
  List<Note> get items => _items;

  Future<void> load({String query = ''}) async {
    _items = await _repository.searchByText(query);
    notifyListeners();
  }

  Future<void> addNote(String content) async {
    final manager = NoteManager(notes: _repository);
    await manager.create(content);
    await load();
  }
}

extension NoteProviderX on BuildContext {
  NoteModel get notes => read<NoteModel>();
}
