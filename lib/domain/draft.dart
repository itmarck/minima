import 'package:minima/domain/sync_status.dart';
import 'package:minima/domain/unique_id.dart';

/// A draft is a quick capture created locally in the launcher.
/// It gets pushed to the Notion Inbox database on sync.
/// The launcher only creates drafts; it never receives them back.
class Draft {
  final UniqueId id;
  final String title;
  final DateTime createdAt;
  final String? notionPageId;
  final SyncStatus syncStatus;

  const Draft({
    required this.id,
    required this.title,
    required this.createdAt,
    this.notionPageId,
    this.syncStatus = SyncStatus.pending,
  });

  Draft copyWith({
    String? notionPageId,
    SyncStatus? syncStatus,
  }) {
    return Draft(
      id: id,
      title: title,
      createdAt: createdAt,
      notionPageId: notionPageId ?? this.notionPageId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
