import 'package:injectable/injectable.dart';
import 'package:jira/core/api_client.dart';
import '../models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Future<ProjectModel> createProject(ProjectModel project);
   Future<List<ProjectModel>> getAllProjects();
   Future<ProjectModel> updateProject(ProjectModel project);

  Future<void> removeProject(String idProject);
}



@Injectable(as: ProjectRemoteDataSource) 
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  
  @override
  Future<ProjectModel> createProject(ProjectModel project) async {
    final response = await ApiClient.dio.post(
      '/projects',
      data: project.toJson(),
    );
    print(response);
    final data = response.data['data'];  
    return ProjectModel.fromJson(data);
  }

  @override
  Future<List<ProjectModel>> getAllProjects() async {
    final response = await ApiClient.dio.get('/projects');
      final jsonData = response.data as Map<String, dynamic>; 
      final dataList = jsonData['data'] as List<dynamic>;    
      final projects = dataList.map((e) => ProjectModel.fromJson(e)).toList();
      return projects;
  }

  @override
  Future<void> removeProject(String idProject) async {
    try {
      final response = await ApiClient.dio.delete('/projects' , data: {'id': idProject});
      if (response.statusCode != 200) {
        throw Exception("Failed to delete project: ${response.statusMessage}");
      }
    }
    catch (e) {
      throw Exception("Unexpected error while deleting project: $e");
    }
  }
  
  @override
  Future<ProjectModel> updateProject(ProjectModel project) async {
    try {
      final response = await ApiClient.dio.put(
        '/projects',
        data: project.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return ProjectModel.fromJson(data);
      } else {
        throw Exception("Failed to update project: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Unexpected error while updating project: $e");
    }
  }


  }
