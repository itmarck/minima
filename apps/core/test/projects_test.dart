import 'package:test/test.dart';

import 'package:core/src/projects/projects.dart';
import 'infrastructure/repositories.dart';

void main() {
  group('Projects flow', () {
    test('create project, job from note, and tasks', () async {
      final projects = InMemoryProjectRepository();
      final jobs = InMemoryJobRepository();
      final tasks = InMemoryTaskRepository();

      final manager = ProjectManager(projects: projects, jobs: jobs, tasks: tasks);

      final project = await manager.createProject(title: 'Knowledge System', description: 'References mgmt');
      expect(project.id.value, isNotEmpty);
      expect(project.title, equals('Knowledge System'));

      final job = await manager.createJobFromNote(project: project, noteContent: 'Research: read clean architecture paper.');
      expect(job.id.value, isNotEmpty);
      expect(job.projectId, equals(project.id));
      expect(job.references, isNotEmpty);
      expect(job.references.first.description, equals(project.title));

      final task1 = await manager.createTask(job: job, title: 'Read paper');
      final task2 = await manager.createTask(job: job, title: 'Summarize findings');
      expect(task1.jobId, equals(job.id));
      expect(task2.jobId, equals(job.id));

      final jobTasks = await manager.getTasksForJob(job.id);
      expect(jobTasks.map((t) => t.id).toSet(), equals({task1.id, task2.id}));

      final toggled = task1.toggle();
      expect(toggled.done, isTrue);
      expect(toggled.id, equals(task1.id));
    });

    test('search projects by text', () async {
      final projects = InMemoryProjectRepository();
      final jobs = InMemoryJobRepository();
      final tasks = InMemoryTaskRepository();
      final manager = ProjectManager(projects: projects, jobs: jobs, tasks: tasks);

      final p1 = await manager.createProject(title: 'Knowledge System', description: 'References mgmt');
      final p2 = await manager.createProject(title: 'Note Engine', description: 'Authoring');

      final hit1 = await projects.searchByText('knowledge');
      expect(hit1.map((p) => p.id).toSet(), equals({p1.id}));

      final hit2 = await projects.searchByText('author');
      expect(hit2.map((p) => p.id).toSet(), equals({p2.id}));

      final miss = await projects.searchByText('unknown');
      expect(miss, isEmpty);
    });
  });
}

