import 'package:core/application.dart';
import 'package:core/domain.dart';
import 'package:core/services.dart';
import 'package:core/src/node.dart';
import 'package:test/test.dart';

class TestNetworkService extends NetworkService {
  @override
  Future<List<Node>> getNodes() async {
    final List<Node> nodes = [];
    return nodes;
  }

  @override
  Future<List<Event>> pull(Node node, {DateTime? since}) {
    throw UnimplementedError();
  }

  @override
  Future<void> push(Node node, List<Event> events) {
    throw UnimplementedError();
  }
}

void main() {
  test('Empty', () async {
    final network = TestNetworkService();
    NetworkManager manager = NetworkManager(network: network);

    final nodes = await manager.getNodes();
    expect(nodes.length, 0);
  });
}
