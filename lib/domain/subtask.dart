import 'package:minima/domain/sync_status.dart';
import 'package:minima/domain/unique_id.dart';

/// A subtask pulled from the Notion Subtasks database.
/// Linked to a parent Task via taskNotionPageId.
/// The launcher can only update its progress (0–100). 100 = done.
class Subtask {
  final UniqueId id;
  final String notionPageId;
  final String taskNotionPageId;
  final String title;
  final int progress;
  final DateTime lastModifiedRemote;
  final DateTime? lastModifiedLocal;
  final SyncStatus syncStatus;

  const Subtask({
    required this.id,
    required this.notionPageId,
    required this.taskNotionPageId,
    required this.title,
    this.progress = 0,
    required this.lastModifiedRemote,
    this.lastModifiedLocal,
    this.syncStatus = SyncStatus.synced,
  });

  Subtask copyWith({
    int? progress,
    DateTime? lastModifiedLocal,
    DateTime? lastModifiedRemote,
    SyncStatus? syncStatus,
  }) {
    return Subtask(
      id: id,
      notionPageId: notionPageId,
      taskNotionPageId: taskNotionPageId,
      title: title,
      progress: progress ?? this.progress,
      lastModifiedRemote: lastModifiedRemote ?? this.lastModifiedRemote,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
