import '../core/reference.dart';
import '../core/unique_id.dart';
import '../notes/note.dart';
import 'job.dart';
import 'job_repository.dart';
import 'project.dart';
import 'project_repository.dart';
import 'task.dart';
import 'task_repository.dart';

class ProjectManager {
  final ProjectRepository _projects;
  final JobRepository _jobs;
  final TaskRepository _tasks;

  ProjectManager({
    required ProjectRepository projects,
    required JobRepository jobs,
    required TaskRepository tasks,
  }) : _projects = projects,
       _jobs = jobs,
       _tasks = tasks;

  Future<List<Project>> searchByText(String query) async {
    return await _projects.searchByText(query);
  }

  Future<Project?> getById(UniqueId id) async {
    return await _projects.getById(id);
  }

  Future<Project> createProject({required String title, required String description}) async {
    final project = Project(
      id: UniqueId.newId(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    await _projects.save(project);
    return project;
  }

  Future<Job> createJob({required Project project, String? title, Note? note}) async {
    final references = <Reference>[];
    final jobTitle = title ?? note?.content ?? 'Untitled';

    if (note != null) {
      references.add(Reference(id: note.id, kind: EntityKind.note));
    }

    final job = Job(
      id: UniqueId.newId(),
      projectId: project.id,
      title: jobTitle,
      createdAt: DateTime.now(),
      references: references,
    );

    await _jobs.save(job);
    return job;
  }

  Future<Task> createTask({required Job job, required String title}) async {
    final task = Task(id: UniqueId.newId(), jobId: job.id, title: title, createdAt: DateTime.now());
    await _tasks.save(task);
    return task;
  }

  Future<List<Task>> getTasksForJob(UniqueId jobId) => _tasks.findByJobId(jobId);
}
