import '../shared/reference.dart';
import '../shared/unique_id.dart';
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
      references: [Reference(id: project.id, kind: EntityKind.project, description: project.title)],
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
