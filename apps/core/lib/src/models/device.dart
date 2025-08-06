import '../../domain.dart';
import '../node.dart';

/// Represent a device in the Tailscale network
class NodeModel {
  static Node from(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final name = json['name'] as String;

    return Node(
      id: UniqueId(id),
      alias: name,
    );
  }
}
