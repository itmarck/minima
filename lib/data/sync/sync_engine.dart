import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:minima/data/remote/notion_client.dart';
import 'package:minima/domain/draft_repository.dart';
import 'package:minima/domain/sync_status.dart';
import 'package:minima/ui/screens/settings_screen.dart';

/// Builds a NotionClient from stored credentials, or returns null if
/// no token is configured.
typedef NotionClientBuilder = Future<NotionClient?> Function();

class SyncEngine {
  final DraftRepository _draftRepository;
  final NotionClientBuilder _clientBuilder;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _syncing = false;

  SyncEngine({
    required DraftRepository draftRepository,
    NotionClientBuilder? clientBuilder,
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  })  : _draftRepository = draftRepository,
        _clientBuilder = clientBuilder ?? _defaultBuilder(storage);

  static NotionClientBuilder _defaultBuilder(FlutterSecureStorage storage) {
    return () async {
      final token = await storage.read(key: SettingsScreen.notionTokenKey);
      final dbId = await storage.read(key: SettingsScreen.notionDatabaseIdKey);

      if (token == null || token.isEmpty || dbId == null || dbId.isEmpty) {
        return null;
      }

      return NotionClient(token: token, inboxDatabaseId: dbId);
    };
  }

  void start() {
    // Try syncing immediately on start.
    syncPendingDrafts();

    // Listen for connectivity changes.
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any(
        (r) => r != ConnectivityResult.none,
      );
      if (hasConnection) {
        syncPendingDrafts();
      }
    });
  }

  void stop() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  Future<void> syncPendingDrafts() async {
    if (_syncing) return;
    _syncing = true;

    try {
      final client = await _clientBuilder();
      if (client == null) return;

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
    } finally {
      _syncing = false;
    }
  }
}
