import 'shared/reference_service.dart';
import 'notes/notes.dart';
import 'projects/projects.dart';

void main(List<String> args) async {
  // Instantiate repositories
  final notes = InMemoryNoteRepository();
  final projects = InMemoryProjectRepository();
  final jobs = InMemoryJobRepository();
  final tasks = InMemoryTaskRepository();

  // Reference service depends on repositories to resolve entities by id
  final referenceService = ReferenceService(
    notes: notes,
    projects: projects,
    jobs: jobs,
    tasks: tasks,
  );

  // Managers
  final noteManager = NoteManager(notes: notes);
  final projectManager = ProjectManager(projects: projects, jobs: jobs, tasks: tasks);

  // 1) Create a Note
  final note = await noteManager.create('Research: read clean architecture paper.');
  print('Note created: ${note.id}');

  // 2) Create a Project
  final project = await projectManager.createProject(
    title: 'Knowledge System',
    description: 'A system to manage notes and projects with references',
  );
  print('Project created: ${project.id} - ${project.title}');

  // 3) Create a Job from a Note (implicit reference to Project)
  final job = await projectManager.createJobFromNote(
    project: project,
    noteContent: note.content,
  );
  print('Job created: ${job.id} - ${job.title}');
  for (final r in job.references) {
    print('  Job reference -> $r');
  }

  // 4) Create Tasks under the Job
  final task1 = await projectManager.createTask(job: job, title: 'Read paper');
  final task2 = await projectManager.createTask(job: job, title: 'Summarize findings');
  print('Tasks created: ${task1.id}, ${task2.id}');

  // 5) Calculated references from text: simulate a note that mentions the job and project IDs
  final textWithRefs = 'Follow up on @<${job.id.value}> and report to @<${project.id.value}>'; 
  final calculatedRefs = await referenceService.extractFromText(textWithRefs);
  print('Calculated references from text:');
  for (final r in calculatedRefs) {
    print('  $r');
  }
}

