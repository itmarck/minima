import '../shared/entity.dart';

class Entry extends Entity {
  final String content;

  const Entry({
    required super.id,
    required this.content,
    required super.createdAt,
    super.references = const [],
  });
}

