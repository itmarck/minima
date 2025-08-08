import 'dart:convert';

import 'package:uuid/uuid.dart';

abstract class Entity {
  final UniqueId id;
  final String? title;
  final String content;
  final DateTime createdAt;

  EntityType get type;
  String? get displayName => title;

  Entity({
    required this.id,
    this.title,
    required this.content,
    required this.createdAt,
  });

  Entity apply(Event event) {
    return this;
  }
}

class Project extends Entity {
  final String description;

  @override
  EntityType get type => EntityType.project;

  Project._reconstruct({
    required super.id,
    required super.title,
    required super.content,
    required super.createdAt,
    required this.description,
  });

  factory Project.fromEvent(ProjectCreated event) {
    return Project._reconstruct(
      id: event.entityId,
      title: event.title,
      content: event.description,
      createdAt: event.ocurredOn,
      description: event.description,
    );
  }

  static Change<Project, Event> create({
    required String title,
    required String content,
    required String description,
  }) {
    final projectId = UniqueId.create();

    return Change(
      entity: Project._reconstruct(
        id: projectId,
        title: title,
        content: content,
        createdAt: DateTime.now(),
        description: description,
      ),
      event: ProjectCreated(
        id: UniqueId.create(),
        version: 1,
        entityId: projectId,
        ocurredOn: DateTime.now(),
        title: title,
        description: description,
      ),
    );
  }
}

// will need a numeric identifier?
class Note extends Entity {
  Note._reconstruct({
    required super.id,
    required super.content,
    required super.createdAt,
  });

  factory Note.fromEvent(NoteCreated event) {
    return Note._reconstruct(
      id: event.entityId,
      content: event.content,
      createdAt: event.ocurredOn,
    );
  }

  @override
  EntityType get type => EntityType.note;

  static Change<Note, Event> create(String content) {
    final noteId = UniqueId.create();
    final entity = Note._reconstruct(
      id: noteId,
      content: content,
      createdAt: DateTime.now(),
    );
    final event = NoteCreated(
      id: UniqueId.create(),
      version: 1,
      entityId: noteId,
      ocurredOn: DateTime.now(),
      content: content,
    );

    return Change(entity: entity, event: event);
  }

  @override
  Note apply(Event event) {
    if (event is NoteCreated) {
      return Note._reconstruct(
        id: event.entityId,
        content: event.content,
        createdAt: event.ocurredOn,
      );
    }

    return this;
  }
}

class Entry extends Entity {
  @override
  EntityType get type => EntityType.entry;

  Entry({required super.id, required super.content, required super.createdAt});
}

class Reference {
  final EntityType entityType;
  final UniqueId source;
  final String? content;

  Reference({required this.entityType, required this.source, this.content});
}

abstract class Event {
  final UniqueId id;
  final int version;
  final UniqueId entityId;
  final DateTime ocurredOn;

  EventName get name;
  Map<String, dynamic> get payload;

  Event({
    required this.id,
    required this.version,
    required this.entityId,
    required this.ocurredOn,
  });
}

class ProjectCreated extends Event {
  final String title;
  final String description;

  @override
  EventName get name => EventName.projectCreated;

  ProjectCreated({
    required super.id,
    required super.version,
    required super.entityId,
    required super.ocurredOn,
    required this.title,
    required this.description,
  });

  @override
  Map<String, dynamic> get payload {
    return {'title': title, 'description': description};
  }
}

class NoteCreated extends Event {
  final String content;

  @override
  EventName get name => EventName.noteCreated;

  NoteCreated({
    required super.id,
    required super.version,
    required super.entityId,
    required super.ocurredOn,
    required this.content,
  });

  factory NoteCreated.from(Map<String, dynamic> json) {
    return NoteCreated(
      id: UniqueId(json['id'] as String),
      version: int.parse(json['version']),
      entityId: UniqueId(json['entity_id'] as String),
      ocurredOn: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      content: jsonDecode(json['payload'])['content'] as String,
    );
  }

  @override
  Map<String, dynamic> get payload {
    return {'content': content};
  }
}

class Change<T extends Entity, E extends Event> {
  final T entity;
  final E event;

  Change({required this.entity, required this.event});
}

enum EntityType {
  project,
  job,
  task,
  note,
  reminder,
  entry,
  tracker, // for habits
}

enum EventName { projectCreated, noteCreated }

extension StringEventNameExtension on String {
  EventName? toEventName() {
    for (final type in EventName.values) {
      if (type.slug == this) {
        return type;
      }
    }
    return null;
  }
}

extension EventNameExtension on EventName {
  String get slug {
    final pattern = RegExp(r'[A-Z]');

    String replace(Match match) {
      return '-${match.group(0)!.toLowerCase()}';
    }

    return name.replaceAllMapped(pattern, replace).replaceFirst('-', '');
  }
}

class UniqueId {
  final String value;

  UniqueId(this.value);

  static UniqueId create() => UniqueId(Uuid().v4());
  static UniqueId get() => UniqueId('00000000-0000-0000-0000-000000000000');

  @override
  bool operator ==(Object other) => other is UniqueId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

enum Fields {
  title,
  subtitle,
  description,
  body,
  url,
  dealine,
  progress, // from 0 to 100
  priority,
  status,
  author,
  createdAt,
  updatedAt,
  deletedAt,
}
