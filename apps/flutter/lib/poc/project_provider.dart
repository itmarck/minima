import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:core/core.dart';

class ProjectModel extends ChangeNotifier {
  final ProjectRepository _repository;

  ProjectModel(this._repository);

  List<Project> _items = const [];
  List<Project> get items => _items;

  Future<void> load({String query = ''}) async {
    _items = await _repository.searchByText(query);
    notifyListeners();
  }

  Future<void> addProject(String title, String description) async {
    final manager = ProjectManager(projects: _repository, jobs: _NoopJobs(), tasks: _NoopTasks());
    await manager.createProject(title: title, description: description);
    await load();
  }
}

class _NoopJobs implements JobRepository {
  @override
  Future<List<Job>> findByProjectId(UniqueId projectId) async => const [];
  @override
  Future<Job?> getById(UniqueId id) async => null;
  @override
  Future<void> save(Job job) async {}
}

class _NoopTasks implements TaskRepository {
  @override
  Future<List<Task>> findByJobId(UniqueId jobId) async => const [];
  @override
  Future<Task?> getById(UniqueId id) async => null;
  @override
  Future<void> save(Task task) async {}
}

extension ProjectProviderX on BuildContext {
  ProjectModel get projects => read<ProjectModel>();
}
