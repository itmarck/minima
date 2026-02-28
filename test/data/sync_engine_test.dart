import 'package:flutter_test/flutter_test.dart';
import 'package:minima/data/remote/notion_client.dart';
import 'package:minima/data/sync/sync_engine.dart';
import 'package:minima/domain/draft.dart';
import 'package:minima/domain/draft_manager.dart';
import 'package:minima/domain/draft_repository.dart';
import 'package:minima/domain/sync_status.dart';

// -- Test doubles --

class InMemoryDraftRepository implements DraftRepository {
  final List<Draft> _drafts = [];

  List<Draft> get drafts => List.unmodifiable(_drafts);

  @override
  Future<void> save(Draft draft) async => _drafts.add(draft);

  @override
  Future<List<Draft>> getAll() async => List.unmodifiable(_drafts);

  @override
  Future<List<Draft>> getByStatus(SyncStatus status) async =>
      _drafts.where((draft) => draft.syncStatus == status).toList();

  @override
  Future<void> updateSyncStatus(
    String id,
    SyncStatus status,
    String notionPageId,
  ) async {
    final index = _drafts.indexWhere((draft) => draft.id.value == id);
    if (index != -1) {
      _drafts[index] = _drafts[index].copyWith(
        syncStatus: status,
        notionPageId: notionPageId,
      );
    }
  }
}

/// A NotionClient that records calls and returns a predictable page ID.
class FakeNotionClient extends NotionClient {
  final List<String> createdTitles = [];
  final String? pageIdToReturn;

  FakeNotionClient({this.pageIdToReturn = 'notion-page-123'})
      : super(token: 'fake-token', inboxDatabaseId: 'fake-db-id');

  @override
  Future<String?> createInboxEntry(String title) async {
    createdTitles.add(title);
    return pageIdToReturn;
  }
}

// -- Tests --

void main() {
  late InMemoryDraftRepository repository;
  late DraftManager manager;

  setUp(() {
    repository = InMemoryDraftRepository();
    manager = DraftManager(repository: repository);
  });

  group('full draft sync flow', () {
    test('create draft then sync marks it as synced with Notion page ID',
        () async {
      final fakeClient = FakeNotionClient();
      final engine = SyncEngine(
        draftRepository: repository,
        clientBuilder: () async => fakeClient,
      );

      // 1. Create a draft (simulates user typing and pressing send).
      await manager.create('Buy groceries');

      // Verify draft is pending.
      final pending = await repository.getByStatus(SyncStatus.pending);
      expect(pending, hasLength(1));
      expect(pending.first.title, 'Buy groceries');

      // 2. Run sync (simulates background trigger).
      await engine.syncPendingDrafts();

      // 3. Verify draft is now synced with a Notion page ID.
      final synced = await repository.getByStatus(SyncStatus.synced);
      expect(synced, hasLength(1));
      expect(synced.first.notionPageId, 'notion-page-123');
      expect(synced.first.title, 'Buy groceries');

      // Verify NotionClient received the correct title.
      expect(fakeClient.createdTitles, ['Buy groceries']);
    });

    test('sync does nothing when no token is configured', () async {
      final engine = SyncEngine(
        draftRepository: repository,
        clientBuilder: () async => null, // No token configured.
      );

      await manager.create('Read book');
      await engine.syncPendingDrafts();

      // Draft should remain pending.
      final pending = await repository.getByStatus(SyncStatus.pending);
      expect(pending, hasLength(1));
      expect(pending.first.title, 'Read book');

      final synced = await repository.getByStatus(SyncStatus.synced);
      expect(synced, isEmpty);
    });

    test('sync skips drafts when Notion API fails', () async {
      final fakeClient = FakeNotionClient(pageIdToReturn: null);
      final engine = SyncEngine(
        draftRepository: repository,
        clientBuilder: () async => fakeClient,
      );

      await manager.create('Call dentist');
      await engine.syncPendingDrafts();

      // Draft should remain pending because Notion returned null.
      final pending = await repository.getByStatus(SyncStatus.pending);
      expect(pending, hasLength(1));
      expect(pending.first.notionPageId, isNull);
    });

    test('sync handles multiple pending drafts', () async {
      final fakeClient = FakeNotionClient();
      final engine = SyncEngine(
        draftRepository: repository,
        clientBuilder: () async => fakeClient,
      );

      await manager.create('Task one');
      await manager.create('Task two');
      await manager.create('Task three');

      await engine.syncPendingDrafts();

      final synced = await repository.getByStatus(SyncStatus.synced);
      expect(synced, hasLength(3));

      expect(
        fakeClient.createdTitles,
        ['Task one', 'Task two', 'Task three'],
      );
    });

    test('already synced drafts are not sent again', () async {
      final fakeClient = FakeNotionClient();
      final engine = SyncEngine(
        draftRepository: repository,
        clientBuilder: () async => fakeClient,
      );

      await manager.create('Only once');
      await engine.syncPendingDrafts();

      // Sync again: nothing new should be sent.
      fakeClient.createdTitles.clear();
      await engine.syncPendingDrafts();

      expect(fakeClient.createdTitles, isEmpty);
    });

    test('partial failure leaves successful drafts synced and failed pending',
        () async {
      var callCount = 0;

      // Selective client that fails on the second call.
      final selectiveClient = _SelectiveNotionClient(
        onCall: (title) {
          callCount++;
          return callCount == 2 ? null : 'page-$callCount';
        },
      );

      final engine = SyncEngine(
        draftRepository: repository,
        clientBuilder: () async => selectiveClient,
      );

      await manager.create('First');
      await manager.create('Second');
      await manager.create('Third');

      await engine.syncPendingDrafts();

      final synced = await repository.getByStatus(SyncStatus.synced);
      final pending = await repository.getByStatus(SyncStatus.pending);

      // First and Third synced, Second failed.
      expect(synced, hasLength(2));
      expect(pending, hasLength(1));
      expect(pending.first.title, 'Second');
    });
  });
}

class _SelectiveNotionClient extends NotionClient {
  final String? Function(String title) onCall;

  _SelectiveNotionClient({required this.onCall})
      : super(token: 'fake', inboxDatabaseId: 'fake');

  @override
  Future<String?> createInboxEntry(String title) async => onCall(title);
}
