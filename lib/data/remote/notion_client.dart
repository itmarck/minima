import 'dart:convert';

import 'package:http/http.dart' as http;

class NotionClient {
  static const _baseUrl = 'https://api.notion.com/v1';
  static const _apiVersion = '2022-06-28'; // 2025-09-03

  final String _token;
  final String _inboxDatabaseId;
  final http.Client _httpClient;

  NotionClient({
    required String token,
    required String inboxDatabaseId,
    http.Client? httpClient,
  })  : _token = token,
        _inboxDatabaseId = inboxDatabaseId,
        _httpClient = httpClient ?? http.Client();

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
        'Notion-Version': _apiVersion,
      };

  /// Pushes a draft to the Notion Inbox database.
  /// Returns the created page ID on success, null on failure.
  Future<String?> createInboxEntry(String title) async {
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
}
