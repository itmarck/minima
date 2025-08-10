import '../core/entity.dart';

class Project extends Entity {
  final String title;
  final String description;

  const Project({
    required super.id,
    required this.title,
    required this.description,
    required super.createdAt,
    super.references = const [],
  });
}

