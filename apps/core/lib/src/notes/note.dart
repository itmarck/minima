import '../shared/entity.dart';
import '../shared/reference.dart';

class Note extends Entity {
  final String content;

  const Note({
    required super.id,
    required this.content,
    super.references = const [],
  });

  Note copyWith({String? content, List<Reference>? references}) => Note(
        id: id,
        content: content ?? this.content,
        references: references ?? this.references,
      );
}

