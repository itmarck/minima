import 'dart:convert';
import 'dart:io';

import 'package:minima/configuration.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

abstract class ServerRoute {
  String get path;

  Future<Response> get(Request request) async {
    return Response.badRequest();
  }

  Future<Response> post(Request request) async {
    return Response.badRequest();
  }
}

class HomeRoute extends ServerRoute {
  @override
  String get path => '/';

  @override
  Future<Response> get(Request request) async {
    return Response.ok(
      jsonEncode({
        'node_id': '0000',
        'version': '0.1.0',
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }
}

class SyncRoute extends ServerRoute {
  @override
  String get path => '/sync';

  @override
  Future<Response> get(Request request) async {
    return Response.ok(jsonEncode({'status': 'get OK'}));
  }

  @override
  Future<Response> post(Request request) async {
    return Response.ok(jsonEncode({'status': 'post OK'}));
  }
}

final List<ServerRoute> routes = [HomeRoute(), SyncRoute()];

class Server {
  final Router _router;
  HttpServer? _server;

  Server() : _router = Router();

  Future<void> start({int port = Configuration.defaultApiPort}) async {
    final handler = Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(logRequests())
        .addHandler(_router.call);

    for (final route in routes) {
      _router.get(route.path, route.get);
      _router.post(route.path, route.post);
    }

    _server = await serve(handler, InternetAddress.anyIPv4, port);
  }

  Future<void> stop() async {
    if (_server == null) return;
    await _server!.close();
    _server = null;
  }
}
