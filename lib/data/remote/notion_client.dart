import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:minima/domain/subtask.dart';
import 'package:minima/domain/task.dart';
import 'package:minima/domain/unique_id.dart';

class NotionClient {
  static const _baseUrl = 'https://api.notion.com/v1';
  static const _apiVersion = '2025-09-03';

  // Notion property names (must match database schema).
  static const _statusProp = 'status';
  static const _doneProp = 'done';
  static const _taskRelationProp = 'task';

  final String _token;
  final String? _inboxDatabaseId;
  final String? _tasksDatabaseId;
  final String? _subtasksDatabaseId;
  final http.Client _httpClient;

  NotionClient({
    required String token,
    String? inboxDatabaseId,
    String? tasksDatabaseId,
    String? subtasksDatabaseId,
    http.Client? httpClient,
  })  : _token = token,
        _inboxDatabaseId = inboxDatabaseId,
        _tasksDatabaseId = tasksDatabaseId,
        _subtasksDatabaseId = subtasksDatabaseId,
        _httpClient = httpClient ?? http.Client();

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
        'Notion-Version': _apiVersion,
      };

  // ── Database discovery ──────────────────────────────────────

  /// Searches all databases the integration has access to.
  /// Returns a map of database title → database ID.
  static Future<Map<String, String>> searchDatabases(
    String token, {
    http.Client? httpClient,
  }) async {
    final client = httpClient ?? http.Client();
    final shouldClose = httpClient == null;

    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/search'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Notion-Version': _apiVersion,
        },
        body: jsonEncode({
          'filter': {'value': 'database', 'property': 'object'},
          'page_size': 100,
        }),
      );

      if (response.statusCode != 200) return {};

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List;
      final databases = <String, String>{};

      for (final db in results) {
        final titleArray = db['title'] as List?;
        if (titleArray == null || titleArray.isEmpty) continue;
        final title = titleArray
            .map((rt) => rt['plain_text'] as String)
            .join()
            .trim();
        if (title.isNotEmpty) {
          databases[title] = db['id'] as String;
        }
      }

      return databases;
    } catch (_) {
      return {};
    } finally {
      if (shouldClose) client.close();
    }
  }

  // ── Inbox (push) ──────────────────────────────────────────────

  /// Pushes a draft to the Notion Inbox database.
  /// Returns the created page ID on success, null on failure.
  Future<String?> createInboxEntry(String title) async {
    if (_inboxDatabaseId == null) return null;

    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/pages'),
        headers: _headers,
        body: jsonEncode({
          'parent': {'database_id': _inboxDatabaseId},
          'properties': {
            'title': {
              'title': [
                {
                  'text': {'content': title},
                },
              ],
            },
            'created': {
              'date': {
                'start': DateTime.now().toUtc().toIso8601String(),
              },
            },
            'source': {
              'select': {'name': 'minima'},
            },
            'status': {
              'select': {'name': 'pending'},
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['id'] as String;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Tasks (pull) ──────────────────────────────────────────────

  /// Fetches non-completed tasks from the Tasks database.
  /// Returns null if no database is configured or on failure.
  Future<List<Task>?> fetchTasks() async {
    if (_tasksDatabaseId == null) return null;

    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/databases/$_tasksDatabaseId/query'),
        headers: _headers,
        body: jsonEncode({
          'filter': {
            'property': _statusProp,
            'select': {'does_not_equal': 'done'},
          },
          'sorts': [
            {'timestamp': 'last_edited_time', 'direction': 'descending'},
          ],
          'page_size': 20,
        }),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List;
      return results.map(_pageToTask).toList();
    } catch (_) {
      return null;
    }
  }

  /// Fetches non-completed subtasks from the Subtasks database.
  /// Returns null if no database is configured or on failure.
  Future<List<Subtask>?> fetchSubtasks() async {
    if (_subtasksDatabaseId == null) return null;

    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/databases/$_subtasksDatabaseId/query'),
        headers: _headers,
        body: jsonEncode({
          'filter': {
            'property': _doneProp,
            'checkbox': {'equals': false},
          },
          'sorts': [
            {'timestamp': 'last_edited_time', 'direction': 'descending'},
          ],
          'page_size': 20,
        }),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List;
      return results.map(_pageToSubtask).toList();
    } catch (_) {
      return null;
    }
  }

  // ── Tasks/Subtasks (push completion) ────────────────────────

  /// Updates a task's status in Notion (e.g. to "done").
  /// Returns true on success.
  Future<bool> updateTaskStatus(String notionPageId, String status) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('$_baseUrl/pages/$notionPageId'),
        headers: _headers,
        body: jsonEncode({
          'properties': {
            _statusProp: {
              'select': {'name': status},
            },
          },
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Updates a subtask's done checkbox in Notion.
  /// Returns true on success.
  Future<bool> updateSubtaskDone(String notionPageId, bool done) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('$_baseUrl/pages/$notionPageId'),
        headers: _headers,
        body: jsonEncode({
          'properties': {
            _doneProp: {
              'checkbox': done,
            },
          },
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Parsers ───────────────────────────────────────────────────

  Task _pageToTask(dynamic page) {
    final props = page['properties'] as Map<String, dynamic>;
    final status = _extractSelectValue(props[_statusProp]);

    return Task(
      id: UniqueId.create(),
      notionPageId: page['id'] as String,
      title: _extractTitle(props),
      status: status.isEmpty ? 'pending' : status,
      completed: status == 'done',
      lastModifiedRemote:
          DateTime.parse(page['last_edited_time'] as String),
    );
  }

  Subtask _pageToSubtask(dynamic page) {
    final props = page['properties'] as Map<String, dynamic>;

    return Subtask(
      id: UniqueId.create(),
      notionPageId: page['id'] as String,
      taskNotionPageId: _extractRelationId(props[_taskRelationProp]),
      title: _extractTitle(props),
      completed: _extractCheckbox(props[_doneProp]),
      lastModifiedRemote:
          DateTime.parse(page['last_edited_time'] as String),
    );
  }

  /// Extracts the title from the first property with type "title".
  String _extractTitle(Map<String, dynamic> properties) {
    for (final prop in properties.values) {
      if (prop is Map && prop['type'] == 'title') {
        final titleArray = prop['title'] as List?;
        if (titleArray == null || titleArray.isEmpty) return '';
        return titleArray.map((rt) => rt['plain_text'] as String).join();
      }
    }
    return '';
  }

  bool _extractCheckbox(dynamic property) {
    if (property == null) return false;
    return property['checkbox'] as bool? ?? false;
  }

  String _extractSelectValue(dynamic property) {
    if (property == null) return '';
    final select = property['select'] as Map<String, dynamic>?;
    if (select == null) return '';
    return select['name'] as String? ?? '';
  }

  String _extractRelationId(dynamic property) {
    if (property == null) return '';
    final relations = property['relation'] as List?;
    if (relations == null || relations.isEmpty) return '';
    return relations.first['id'] as String;
  }
}
