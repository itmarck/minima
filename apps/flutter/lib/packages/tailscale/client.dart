import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../../configuration.dart';

class TailscaleClient {
  final String? _tailnet;
  String? _token;

  static const String _baseUrl = Configuration.tailscaleApiBaseUrl;

  TailscaleClient({String? accessToken, String? tailnet})
    : _tailnet = tailnet ?? Configuration.tailscaleDefaultTailnet,
      _token = accessToken;

  Map<String, String> get _headers {
    if (_token == null) {
      return {};
    }

    return {
      HttpHeaders.authorizationHeader: 'Bearer $_token',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  Future<List> getDevices() async {
    try {
      return await _request('/devices');
    } catch (error) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getOwnerUser(String deviceId) async {
    try {
      final users = await _request('/users?role=owner');
      return users.first;
    } catch (error) {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> _request(String path) async {
    final uri = '$_baseUrl/tailnet/$_tailnet$path';
    final response = await get(Uri.parse(uri), headers: _headers);

    if (response.statusCode == 401) {
      _token = null;
      return [];
    }

    if (response.statusCode != 200) {
      return [];
    }

    return jsonDecode(response.body) as List<Map<String, dynamic>>;
  }
}
