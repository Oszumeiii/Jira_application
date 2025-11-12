import 'package:injectable/injectable.dart';
import 'package:jira/core/api_client.dart';
import '../models/project_model.dart';

abstract class ProjectRemoteDataSource {
  //Future<ProjectModel> createProject(ProjectModel project);
   Future<List<ProjectModel>> getAllProjects();
}



@Injectable(as: ProjectRemoteDataSource) //khi injectable tạo instance sẽ tạo instance của ProjectRemoteDataSourceImpl
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  //@override
  // Future<ProjectModel> createProject(ProjectModel project) async {
  //   final response = await ApiClient.dio.post(
  //     '/projects',
  //     data: project.toJson(),
  //   );
  //   return ProjectModel.fromJson(response.data);
  // }

  @override
Future<List<ProjectModel>> getAllProjects() async {
  final response = await ApiClient.dio.get('/projects');
    final jsonData = response.data as Map<String, dynamic>; 
    final dataList = jsonData['data'] as List<dynamic>;    
    final projects = dataList.map((e) => ProjectModel.fromJson(e)).toList();
    return projects;
      }
}
