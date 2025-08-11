import 'package:core/core.dart';
import 'package:test/test.dart';

import 'infrastructure/repositories.dart';

void main() {
  group('References', () {
    test('create reference to a note in the job', () async {
      final noteManager = NoteManager(notes: InMemoryNoteRepository());
      final projectManager = ProjectManager(
        projects: InMemoryProjectRepository(),
        jobs: InMemoryJobRepository(),
        tasks: InMemoryTaskRepository(),
      );

      final note = await noteManager.create('test note');
      final project = await projectManager.createProject(title: 'test', description: '');

      final job = await projectManager.createJob(project: project, title: 'test job', note: note);
      expect(job.id.value, isNotEmpty);
      expect(job.projectId, equals(project.id));
      expect(job.references, hasLength(1));
    });
  });
}
