import 'package:injectable/injectable.dart';
import 'package:jira/features/dash_board/projects/domain/repositories/project_repository.dart';
import '../entities/project_entity.dart';



// Retrieve all projects usecase


@injectable
class GetAllProjectsUsecase {
  final ProjectRepository repository;

  GetAllProjectsUsecase(this.repository);
  Future<List<ProjectEntity>> call() async {
      return repository.getAllProjects();
    }
}
