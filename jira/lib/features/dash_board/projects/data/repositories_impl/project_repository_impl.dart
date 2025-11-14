import 'package:injectable/injectable.dart';
import 'package:jira/features/dash_board/projects/data/data_source/project_remote_datasource.dart';
import 'package:jira/features/dash_board/projects/data/models/project_model.dart';
import 'package:jira/features/dash_board/projects/domain/entities/project_entity.dart';
import 'package:jira/features/dash_board/projects/domain/repositories/project_repository.dart';


// Implement the ProjectRepository interface to handle project data operations.

@Injectable(as: ProjectRepository)
class ProjectRepositoryImpl extends ProjectRepository{
  final  ProjectRemoteDataSource remoteDataSource;
  ProjectRepositoryImpl(this.remoteDataSource);

  
  @override
  Future<ProjectEntity> createProject(ProjectEntity project) {
    final projectModel = ProjectModel(
      id: project.id,
      name: project.name,
      priority : project.priority , 
      projectType: project.projectType,
      sumary: project.sumary,
      description: project.description,
      ownerId: project.ownerId,
      members: project.members,
      status: project.status,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
    );
    print(project);
    return remoteDataSource.createProject(projectModel);
  }
  
@override
Future<List<ProjectEntity>> getAllProjects() async {
  final projectModels = await remoteDataSource.getAllProjects();
  final projects = projectModels.map((m) => m.toEntity()).toList();
  return projects;
}

  @override
  Future<void> removeProject(String idProject) async{
    try {
          await remoteDataSource.removeProject(idProject);
    } catch (e) {
      throw Exception("Repository: failed to remove project - $e");
    }
  }




}