
import 'package:injectable/injectable.dart';
import 'package:jira/features/dash_board/projects/domain/entities/project_entity.dart';
import 'package:jira/features/dash_board/projects/domain/repositories/project_repository.dart';

@injectable
class UpdateProjectUsecase {
  final ProjectRepository repository;
  UpdateProjectUsecase(this.repository);

  Future<ProjectEntity> call(ProjectEntity project) async {
    try {
      return await repository.updateProject(project);
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }
}
