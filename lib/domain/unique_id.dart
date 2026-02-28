import 'package:uuid/uuid.dart';

class UniqueId {
  final String value;

  const UniqueId(this.value);

  factory UniqueId.create() => UniqueId(const Uuid().v4());

  @override
  bool operator ==(Object other) => other is UniqueId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
