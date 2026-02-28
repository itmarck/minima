import 'package:minima/domain/sync_status.dart';
import 'package:minima/domain/unique_id.dart';

/// A task pulled from the Notion Tasks database.
/// The launcher can only change its status (e.g. mark as completed).
/// It never creates or deletes tasks directly.
class Task {
  final UniqueId id;
  final String notionPageId;
  final String title;
  final bool completed;
  final DateTime lastModifiedRemote;
  final DateTime? lastModifiedLocal;
  final SyncStatus syncStatus;

  const Task({
    required this.id,
    required this.notionPageId,
    required this.title,
    required this.completed,
    required this.lastModifiedRemote,
    this.lastModifiedLocal,
    this.syncStatus = SyncStatus.synced,
  });

  Task copyWith({
    bool? completed,
    DateTime? lastModifiedLocal,
    DateTime? lastModifiedRemote,
    SyncStatus? syncStatus,
  }) {
    return Task(
      id: id,
      notionPageId: notionPageId,
      title: title,
      completed: completed ?? this.completed,
      lastModifiedRemote: lastModifiedRemote ?? this.lastModifiedRemote,
      lastModifiedLocal: lastModifiedLocal ?? this.lastModifiedLocal,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
