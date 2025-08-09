import '../shared/entity.dart';
import '../shared/reference.dart';
import '../shared/unique_id.dart';

class Project extends Entity {
  final String title;
  final String description;

  const Project({
    required super.id,
    required this.title,
    required this.description,
    super.references = const [],
  });
}

class Job extends Entity {
  final UniqueId projectId;
  final String title;

  const Job({
    required super.id,
    required this.projectId,
    required this.title,
    super.references = const [],
  });
}

class Task extends Entity {
  final UniqueId jobId;
  final String title;
  final bool done;

  const Task({
    required super.id,
    required this.jobId,
    required this.title,
    this.done = false,
    super.references = const [],
  });

  Task toggle() => Task(
        id: id,
        jobId: jobId,
        title: title,
        done: !done,
        references: references,
      );
}

abstract class ProjectRepository {
  Future<void> save(Project project);
  Future<Project?> getById(UniqueId id);
  Future<List<Project>> searchByText(String query);
}

abstract class JobRepository {
  Future<void> save(Job job);
  Future<Job?> getById(UniqueId id);
  Future<List<Job>> findByProjectId(UniqueId projectId);
}

abstract class TaskRepository {
  Future<void> save(Task task);
  Future<Task?> getById(UniqueId id);
  Future<List<Task>> findByJobId(UniqueId jobId);
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

class ProjectManager {
  final ProjectRepository _projects;
  final JobRepository _jobs;
  final TaskRepository _tasks;

  ProjectManager({
    required ProjectRepository projects,
    required JobRepository jobs,
    required TaskRepository tasks,
  })  : _projects = projects,
        _jobs = jobs,
        _tasks = tasks;

  Future<Project> createProject({required String title, required String description}) async {
    final project = Project(id: UniqueId.newId(), title: title, description: description);
    await _projects.save(project);
    return project;
  }

  Future<Job> createJobFromNote({required Project project, required String noteContent}) async {
    final job = Job(
      id: UniqueId.newId(),
      projectId: project.id,
      title: noteContent.length > 50 ? noteContent.substring(0, 50) : noteContent,
      references: [
        Reference(
          id: project.id,
          kind: EntityKind.project,
          description: project.title,
        )
      ],
    );
    await _jobs.save(job);
    return job;
  }

  Future<Task> createTask({required Job job, required String title}) async {
    final task = Task(id: UniqueId.newId(), jobId: job.id, title: title);
    await _tasks.save(task);
    return task;
  }

  Future<List<Task>> getTasksForJob(UniqueId jobId) => _tasks.findByJobId(jobId);
}

