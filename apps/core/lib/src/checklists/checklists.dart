import '../core/entity.dart';
import '../core/unique_id.dart';

class Checklist extends Entity {
  final String title;
  final bool loopable; // monthly for now
  final List<Checkitem> items;

  const Checklist({
    required super.id,
    required this.title,
    this.loopable = false,
    this.items = const [],
    required super.createdAt,
    super.references = const [],
  });
}

class Checkitem extends Entity {
  final String content;
  final bool checked;

  Checkitem({
    required super.id,
    required this.content,
    this.checked = false,
    required super.createdAt,
    super.references = const [],
  });
}

abstract class ChecklistRepository {
  Future<void> save(Checklist checklist);
  Future<List<Checklist>> getAll();
}

class ChecklistManager {
  ChecklistRepository _repository;

  ChecklistManager({required ChecklistRepository repository}) : _repository = repository;

  Future<List<Checklist>> getAll() {
    return _repository.getAll();
  }

  Future<Checklist> createList(String title, [List<String> items = const []]) async {
    final checklist = Checklist(
      id: UniqueId.newId(),
      title: title,
      items: items.map(buildItem).toList(),
      createdAt: DateTime.now(),
    );
    await _repository.save(checklist);
    return checklist;
  }

  Future<Checklist> addItemsToChecklist(Checklist checklist, List<String> items) async {
    checklist.items.addAll(items.map(buildItem).toList());
    await _repository.save(checklist);
    return checklist;
  }

  Checkitem buildItem(String content) {
    return Checkitem(id: UniqueId.newId(), content: content, createdAt: DateTime.now());
  }
}
