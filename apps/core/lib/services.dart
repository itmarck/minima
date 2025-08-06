import 'package:core/domain.dart';
import 'package:core/src/node.dart';

abstract class NetworkService {
  Future<List<Node>> getNodes();

  Future<void> push(Node node, List<Event> events);
  Future<List<Event>> pull(Node node, {DateTime? since});
}
