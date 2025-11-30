import 'package:injectable/injectable.dart';
import 'package:jira/core/injection.dart';
import 'package:jira/features/dash_board/Issues/domain/Usecase/get_issue_by_project_usecase.dart';
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
    return remoteDataSource.createProject(projectModel);
  }
  
@override
Future<List<ProjectEntity>> getAllProjects() async {
  // Lấy dữ liệu từ remoteDataSource
  final projectModels = await remoteDataSource.getAllProjects();

  // Tính progress cho từng project
  final projectsWithProgress = await Future.wait(
    projectModels.map((project) async {
      double progress = 0.0;
      try {
        final getIssueUsecase = getIt<GetIssueByProjectUsecase>();
        final issues = await getIssueUsecase.call(project.id!);
        if (issues.isNotEmpty) {
          final completed = issues.where((issue) => issue.status.toLowerCase() == 'done').length;
          progress = completed / issues.length;
        }
      } catch (e) {
        print("Error fetching progress for project ${project.id}: $e");
      }

      // Trả về ProjectModel đã có progress, chuyển thành Entity
      return project.copyWith(progress: progress).toEntity();
    }),
  );

  return projectsWithProgress;
}


  @override
  Future<void> removeProject(String idProject) async{
    try {
          await remoteDataSource.removeProject(idProject);
    } catch (e) {
      throw Exception("Repository: failed to remove project - $e");
    }
  }
  
  @override
  Future<ProjectEntity> updateProject(ProjectEntity project) async {
    final projectModel = ProjectModel.fromEntity(project);
     ProjectModel result = await remoteDataSource.updateProject(projectModel);
    return result.toEntity();
  }




}