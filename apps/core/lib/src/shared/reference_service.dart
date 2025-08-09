import '../notes/notes.dart';
import '../projects/projects.dart';
import 'reference.dart';
import 'unique_id.dart';

/// Service that extracts and resolves references inside text content.
/// It merges both calculated references (from text like `@<uuid>`) and implicit
/// references created by application logic.
class ReferenceService {
  final NoteRepository _notes;
  final ProjectRepository _projects;
  final JobRepository _jobs;
  final TaskRepository _tasks;

  ReferenceService({
    required NoteRepository notes,
    required ProjectRepository projects,
    required JobRepository jobs,
    required TaskRepository tasks,
  })  : _notes = notes,
        _projects = projects,
        _jobs = jobs,
        _tasks = tasks;

  /// Extract references from free text. Pattern: `@<uuid>`
  Future<List<Reference>> extractFromText(String text) async {
    final regex = RegExp(r'@<([0-9a-fA-F\-]{36})>');
    final matches = regex.allMatches(text);
    final refs = <Reference>[];

    for (final m in matches) {
      final idStr = m.group(1)!;
      final id = UniqueId.fromString(idStr);
      final ref = await _resolveById(id);
      if (ref != null) refs.add(ref);
    }

    return refs;
  }

  /// Attempt to resolve a UniqueId to a typed Reference by consulting repositories.
  Future<Reference?> _resolveById(UniqueId id) async {
    final project = await _projects.getById(id);
    if (project != null) {
      return Reference(id: project.id, kind: EntityKind.project, description: project.title);
    }

    final job = await _jobs.getById(id);
    if (job != null) {
      return Reference(id: job.id, kind: EntityKind.job, description: job.title);
    }

    final task = await _tasks.getById(id);
    if (task != null) {
      return Reference(id: task.id, kind: EntityKind.task, description: task.title);
    }

    final note = await _notes.getById(id);
    if (note != null) {
      final preview = note.content.length > 50 ? note.content.substring(0, 50) : note.content;
      return Reference(id: note.id, kind: EntityKind.note, description: preview);
    }

    return null;
  }
}

