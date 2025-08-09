import '../shared/unique_id.dart';
import 'job.dart';

abstract class JobRepository {
  Future<void> save(Job job);
  Future<Job?> getById(UniqueId id);
  Future<List<Job>> findByProjectId(UniqueId projectId);
}

