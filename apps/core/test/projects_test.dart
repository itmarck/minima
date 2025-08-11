import 'package:core/core.dart';
import 'package:test/test.dart';

import 'infrastructure/repositories.dart';

void main() {
  group('Projects', () {
    test('create project, job from note, and tasks', () async {
      final manager = ProjectManager(
        projects: InMemoryProjectRepository(),
        jobs: InMemoryJobRepository(),
        tasks: InMemoryTaskRepository(),
      );

      final project = await manager.createProject(title: 'test', description: 'test description');
      expect(project.id.value, isNotEmpty);
      expect(project.title, equals('test'));

      final job = await manager.createJob(project: project, title: 'learn about ai');
      expect(job.id.value, isNotEmpty);
      expect(job.projectId, equals(project.id));
      expect(job.references, isEmpty);

      final task1 = await manager.createTask(job: job, title: 'read docs');
      final task2 = await manager.createTask(job: job, title: 'summarize findings');
      expect(task1.jobId, equals(job.id));
      expect(task2.jobId, equals(job.id));

      final jobTasks = await manager.getTasksForJob(job.id);
      expect(jobTasks.length, equals(2));

      final toggled = task1.toggle();
      expect(toggled.id, equals(task1.id));
      expect(toggled.done, isTrue);
    });

    test('get all projects', () async {
      final manager = ProjectManager(
        projects: InMemoryProjectRepository(),
        jobs: InMemoryJobRepository(),
        tasks: InMemoryTaskRepository(),
      );

      final emptyProjects = await manager.searchByText('');
      expect(emptyProjects.length, equals(0));

      await manager.createProject(title: 'programming', description: '');
      await manager.createProject(title: 'english', description: 'practice');

      final projects = await manager.searchByText('');
      expect(projects.length, equals(2));
    });
  });
}
