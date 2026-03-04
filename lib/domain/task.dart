import 'package:minima/domain/sync_status.dart';
import 'package:minima/domain/unique_id.dart';

/// A task pulled from the Notion Tasks database.
/// The launcher can only update its progress (0–100). 100 = done.
/// It never creates or deletes tasks directly.
class Task {
  final UniqueId id;
  final String notionPageId;
  final String title;
  final int progress;
  final DateTime lastModifiedRemote;
  final DateTime? lastModifiedLocal;
  final SyncStatus syncStatus;

  const Task({
    required this.id,
    required this.notionPageId,
    required this.title,
    this.progress = 0,
    required this.lastModifiedRemote,
    this.lastModifiedLocal,
    this.syncStatus = SyncStatus.synced,
  });

  Task copyWith({
    int? progress,
    DateTime? lastModifiedLocal,
    DateTime? lastModifiedRemote,
    SyncStatus? syncStatus,
  }) {
    return Task(
      id: id,
      notionPageId: notionPageId,
      title: title,
      progress: progress ?? this.progress,
      lastModifiedRemote: lastModifiedRemote ?? this.lastModifiedRemote,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
