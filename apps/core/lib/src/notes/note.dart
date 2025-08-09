import '../shared/entity.dart';

class Note extends Entity {
  final String content;

  const Note({
    required super.id,
    required this.content,
    required super.createdAt,
    super.references = const [],
  });
}
