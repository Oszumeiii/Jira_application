import 'package:injectable/injectable.dart';
import 'package:jira/features/dash_board/projects/domain/repositories/project_repository.dart';
import '../entities/project_entity.dart';





// Create a new project usecase
@injectable
class CreateProjectUseCase {
  final ProjectRepository repository;

  CreateProjectUseCase(this.repository);
  // Create a new project
  Future<ProjectEntity> call(ProjectEntity project) {
    return repository.createProject(project);
  }
}
