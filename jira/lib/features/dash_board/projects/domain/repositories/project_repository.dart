import 'package:jira/features/dash_board/projects/domain/entities/project_entity.dart';

// Define the ProjectRepository abstract class that declares methods for creating and retrieving projects.

abstract class ProjectRepository {

  //Define method to create a new project
  Future<ProjectEntity> createProject(ProjectEntity project);

  //Define method to retrieve all projects
  Future<List<ProjectEntity>> getAllProjects();
}