import 'package:flutter_test/flutter_test.dart';
import 'package:minima/domain/draft.dart';
import 'package:minima/domain/draft_manager.dart';
import 'package:minima/domain/draft_repository.dart';
import 'package:minima/domain/sync_status.dart';

class InMemoryDraftRepository implements DraftRepository {
  final List<Draft> _drafts = [];

  @override
  Future<void> save(Draft draft) async => _drafts.add(draft);

  @override
  Future<List<Draft>> getAll() async => List.unmodifiable(_drafts);

  @override
  Future<List<Draft>> getByStatus(SyncStatus status) async =>
      _drafts.where((d) => d.syncStatus == status).toList();

  @override
  Future<void> updateSyncStatus(
    String id,
    SyncStatus status,
    String notionPageId,
  ) async {
    final index = _drafts.indexWhere((d) => d.id.value == id);
    if (index != -1) {
      _drafts[index] = _drafts[index].copyWith(
        syncStatus: status,
        notionPageId: notionPageId,
      );
    }
  }
}

void main() {
  late InMemoryDraftRepository repository;
  late DraftManager manager;

  setUp(() {
    repository = InMemoryDraftRepository();
    manager = DraftManager(repository: repository);
  });

  test('create stores a draft with pending sync status', () async {
    final draft = await manager.create('Buy groceries');

    expect(draft.title, 'Buy groceries');
    expect(draft.syncStatus, SyncStatus.pending);
    expect(draft.notionPageId, isNull);

    final all = await manager.getAll();
    expect(all, hasLength(1));
    expect(all.first.id, draft.id);
  });

  test('create trims whitespace from title', () async {
    final draft = await manager.create('  Buy groceries  ');
    expect(draft.title, 'Buy groceries');
  });

  test('drafts start as pending and can be marked as synced', () async {
    final draft = await manager.create('Read book');

    final pending = await repository.getByStatus(SyncStatus.pending);
    expect(pending, hasLength(1));

    await repository.updateSyncStatus(
      draft.id.value,
      SyncStatus.synced,
      'notion-page-123',
    );

    final synced = await repository.getByStatus(SyncStatus.synced);
    expect(synced, hasLength(1));
    expect(synced.first.notionPageId, 'notion-page-123');
  });
}
