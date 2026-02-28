import 'package:minima/domain/draft.dart';
import 'package:minima/domain/draft_repository.dart';
import 'package:minima/domain/unique_id.dart';

class DraftManager {
  final DraftRepository _repository;

  DraftManager({required DraftRepository repository})
      : _repository = repository;

  Future<Draft> create(String title) async {
    final draft = Draft(
      id: UniqueId.create(),
      title: title.trim(),
      createdAt: DateTime.now(),
    );
    await _repository.save(draft);
    return draft;
  }

  Future<List<Draft>> getAll() => _repository.getAll();
}
