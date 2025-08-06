library core;

import 'dart:async';

import 'package:uuid/uuid.dart';

export 'src/models/device.dart';
export 'src/node.dart';
export 'src/owner.dart';

/// Main class that orchestrates the system
class Core {
  late final String _nodeId;

  bool _initialized = false;

  /// Get the unique node identifier
  String get nodeId => _nodeId;

  /// Initialize the core system
  Future<void> initialize({
    String? customNodeId,
    int apiPort = 8080,
    String? tailscaleAccessToken,
  }) async {
    if (_initialized) return;

    // Generate or retrieve node ID
    _nodeId = customNodeId ?? await _getOrCreateNodeId();

    _initialized = true;
  }

  /// Start server
  Future<void> startServer() async {}

  /// Shutdown the core system
  Future<void> shutdown() async {
    if (!_initialized) return;

    _initialized = false;
  }

  /// Wipe all data and reinitialize system
  Future<void> wipeAllData() async {
    if (!_initialized) return;

    print('Core system reinitialized after data wipe');
  }

  /// Get or create a persistent node ID
  /// TODO: This value should be moved to the database
  Future<String> _getOrCreateNodeId() async {
    try {
      return '';
    } catch (e) {
      // Fallback to memory-only UUID if file operations fail
      const uuid = Uuid();
      return uuid.v4();
    }
  }
}
