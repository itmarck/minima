import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:minima/data/remote/notion_client.dart';
import 'package:minima/domain/draft_repository.dart';
import 'package:minima/domain/subtask_repository.dart';
import 'package:minima/domain/sync_status.dart';
import 'package:minima/domain/task_repository.dart';
import 'package:minima/ui/screens/settings_screen.dart';

/// Builds a NotionClient from stored credentials, or returns null if
/// no token is configured.
typedef NotionClientBuilder = Future<NotionClient?> Function();

class SyncEngine {
  final DraftRepository _draftRepository;
  final TaskRepository? _taskRepository;
  final SubtaskRepository? _subtaskRepository;
  final NotionClientBuilder _clientBuilder;

  /// Called after a full sync completes (pull included) so the UI can refresh.
  VoidCallback? onSyncComplete;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _syncing = false;

  SyncEngine({
    required DraftRepository draftRepository,
    TaskRepository? taskRepository,
    SubtaskRepository? subtaskRepository,
    NotionClientBuilder? clientBuilder,
    FlutterSecureStorage storage = const FlutterSecureStorage(),
    this.onSyncComplete,
  })  : _draftRepository = draftRepository,
        _taskRepository = taskRepository,
        _subtaskRepository = subtaskRepository,
        _clientBuilder = clientBuilder ?? _defaultBuilder(storage);

  static NotionClientBuilder _defaultBuilder(FlutterSecureStorage storage) {
    return () async {
      final token = await storage.read(key: SettingsScreen.notionTokenKey);
      if (token == null || token.isEmpty) return null;

      var inboxId =
          await storage.read(key: SettingsScreen.notionDatabaseIdKey);
      var tasksId =
          await storage.read(key: SettingsScreen.notionTasksDatabaseIdKey);
      var subtasksId =
          await storage.read(key: SettingsScreen.notionSubtasksDatabaseIdKey);

      // Auto-discover database IDs if any are missing.
      if (inboxId == null || tasksId == null || subtasksId == null) {
        final databases = await NotionClient.searchDatabases(token);

        for (final entry in databases.entries) {
          final name = entry.key.toLowerCase();
          final id = entry.value;

          if (inboxId == null && name == 'inbox') {
            inboxId = id;
            await storage.write(
              key: SettingsScreen.notionDatabaseIdKey,
              value: id,
            );
          } else if (tasksId == null && name == 'tasks') {
            tasksId = id;
            await storage.write(
              key: SettingsScreen.notionTasksDatabaseIdKey,
              value: id,
            );
          } else if (subtasksId == null && name == 'subtasks') {
            subtasksId = id;
            await storage.write(
              key: SettingsScreen.notionSubtasksDatabaseIdKey,
              value: id,
            );
          }
        }
      }

      return NotionClient(
        token: token,
        inboxDatabaseId: inboxId,
        tasksDatabaseId: tasksId,
        subtasksDatabaseId: subtasksId,
      );
    };
  }

  void start() {
    // Full sync on start (push + pull).
    sync();

    // Listen for connectivity changes.
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any(
        (r) => r != ConnectivityResult.none,
      );
      if (hasConnection) {
        sync();
      }
    });
  }

  void stop() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Full sync cycle: push all pending changes, pull tasks + subtasks, notify UI.
  Future<void> sync() async {
    if (_syncing) return;
    _syncing = true;

    try {
      final client = await _clientBuilder();
      if (client == null) return;

      // Push first, then pull fresh data.
      await _pushPendingDrafts(client);
      await _pushPendingTasks(client);
      await _pushPendingSubtasks(client);
      await _pullTasks(client);
      await _pullSubtasks(client);

      onSyncComplete?.call();
    } finally {
      _syncing = false;
    }
  }

  /// Push-only sync (called after draft creation to avoid pulling unnecessarily).
  Future<void> syncPendingDrafts() async {
    if (_syncing) return;
    _syncing = true;

    try {
      final client = await _clientBuilder();
      if (client == null) return;

      await _pushPendingDrafts(client);
    } finally {
      _syncing = false;
    }
  }

  Future<void> _pushPendingDrafts(NotionClient client) async {
    final pending = await _draftRepository.getByStatus(SyncStatus.pending);

    for (final draft in pending) {
      final notionPageId = await client.createInboxEntry(draft.title);
      if (notionPageId != null) {
        await _draftRepository.updateSyncStatus(
          draft.id.value,
          SyncStatus.synced,
          notionPageId,
        );
      }
    }
  }

  Future<void> _pushPendingTasks(NotionClient client) async {
    if (_taskRepository == null) return;

    final pending = await _taskRepository.getByStatus(SyncStatus.pending);

    for (final task in pending) {
      final success = await client.updateTaskProgress(
        task.notionPageId,
        100,
      );
      if (success) {
        await _taskRepository.upsert(
          task.copyWith(syncStatus: SyncStatus.synced),
        );
      }
    }
  }

  Future<void> _pushPendingSubtasks(NotionClient client) async {
    if (_subtaskRepository == null) return;

    final pending = await _subtaskRepository.getByStatus(SyncStatus.pending);

    for (final subtask in pending) {
      final success = await client.updateSubtaskProgress(
        subtask.notionPageId,
        100,
      );
      if (success) {
        await _subtaskRepository.upsert(
          subtask.copyWith(syncStatus: SyncStatus.synced),
        );
      }
    }
  }

  Future<void> _pullTasks(NotionClient client) async {
    if (_taskRepository == null) return;

    final tasks = await client.fetchTasks();
    if (tasks != null) {
      await _taskRepository.upsertAll(tasks);
    }
  }

  Future<void> _pullSubtasks(NotionClient client) async {
    if (_subtaskRepository == null) return;

    final subtasks = await client.fetchSubtasks();
    if (subtasks != null) {
      await _subtaskRepository.upsertAll(subtasks);
    }
  }
}
