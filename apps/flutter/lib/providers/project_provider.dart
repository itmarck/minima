import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectManager _manager;

  ProjectProvider({
    required ProjectRepository projects,
    required JobRepository jobs,
    required TaskRepository tasks,
  }) : _manager = ProjectManager(projects: projects, jobs: jobs, tasks: tasks);

  List<Project> _items = const [];
  List<Project> get items => _items;

  Future<void> load({String query = ''}) async {
    _items = await _manager.searchByText(query);
    notifyListeners();
  }

  Future<Project> addProject(String title, String description) async {
    final project = await _manager.createProject(title: title, description: description);
    await load();
    return project;
  }

  Future<Project?> getById(UniqueId id) => _manager.getById(id);

  static ProjectProvider of(BuildContext context) {
    return Provider.of<ProjectProvider>(context, listen: false);
  }
}
