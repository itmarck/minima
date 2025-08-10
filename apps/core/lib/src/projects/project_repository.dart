import '../core/unique_id.dart';
import 'project.dart';

abstract class ProjectRepository {
  Future<void> save(Project project);
  Future<Project?> getById(UniqueId id);
  Future<List<Project>> searchByText(String query);
}

