
import 'package:injectable/injectable.dart';
import 'package:jira/features/dash_board/projects/domain/repositories/project_repository.dart';

@injectable
class UpdateProjectUsecase {
  final ProjectRepository repository;
  UpdateProjectUsecase(this.repository);

  Future <void> call (String idProject) async {
    try {
      await repository.removeProject(idProject);
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

}