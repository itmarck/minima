import 'package:core/src/notes/notes.dart';
import 'package:core/src/projects/projects.dart';
import 'package:core/src/shared/unique_id.dart';

class InMemoryNoteRepository implements NoteRepository {
  final Map<String, Note> _store = {};

  @override
  Future<Note?> getById(UniqueId id) async => _store[id.value];

  @override
  Future<void> save(Note note) async {
    _store[note.id.value] = note;
  }

  @override
  Future<List<Note>> searchByText(String query) async {
    final q = query.toLowerCase();
    return _store.values.where((n) => n.content.toLowerCase().contains(q)).toList(growable: false);
  }
}

class InMemoryProjectRepository implements ProjectRepository {
  final Map<String, Project> _store = {};

  @override
  Future<Project?> getById(UniqueId id) async => _store[id.value];

  @override
  Future<void> save(Project project) async {
    _store[project.id.value] = project;
  }

  @override
  Future<List<Project>> searchByText(String query) async {
    final q = query.toLowerCase();
    return _store.values
        .where((p) => p.title.toLowerCase().contains(q) || p.description.toLowerCase().contains(q))
        .toList(growable: false);
  }
}

class InMemoryJobRepository implements JobRepository {
  final Map<String, Job> _store = {};

  @override
  Future<Job?> getById(UniqueId id) async => _store[id.value];

  @override
  Future<void> save(Job job) async {
    _store[job.id.value] = job;
  }

  @override
  Future<List<Job>> findByProjectId(UniqueId projectId) async {
    return _store.values.where((j) => j.projectId == projectId).toList(growable: false);
  }
}

class InMemoryTaskRepository implements TaskRepository {
  final Map<String, Task> _store = {};

  @override
  Future<Task?> getById(UniqueId id) async => _store[id.value];

  @override
  Future<void> save(Task task) async {
    _store[task.id.value] = task;
  }

  @override
  Future<List<Task>> findByJobId(UniqueId jobId) async {
    return _store.values.where((t) => t.jobId == jobId).toList(growable: false);
  }
}
