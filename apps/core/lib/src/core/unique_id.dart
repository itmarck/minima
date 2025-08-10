import 'package:uuid/uuid.dart';

/// Value Object representing a globally unique identifier for entities and aggregates.
class UniqueId {
  final String value;

  const UniqueId._(this.value);

  /// Creates a new random UUID v4.
  factory UniqueId.newId() => UniqueId._(const Uuid().v4());

  /// Creates a UniqueId from an existing string. Throws if not a valid UUID.
  factory UniqueId.fromString(String raw) {
    final normalized = raw.trim();
    if (!_isValidUuid(normalized)) {
      throw ArgumentError('Invalid UUID string: $raw');
    }
    return UniqueId._(normalized);
  }

  /// Returns the raw UUID string value.
  @override
  String toString() => value;

  @override
  bool operator ==(Object other) => other is UniqueId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  static bool _isValidUuid(String value) {
    // Accept common UUID formats (v4 default from package:uuid)
    return Uuid.isValidUUID(fromString: value);
  }
}
