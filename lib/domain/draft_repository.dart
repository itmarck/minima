import 'package:minima/domain/draft.dart';
import 'package:minima/domain/sync_status.dart';

abstract class DraftRepository {
  Future<void> save(Draft draft);
  Future<List<Draft>> getAll();
  Future<List<Draft>> getByStatus(SyncStatus status);
  Future<void> updateSyncStatus(String id, SyncStatus status, String notionPageId);
}
