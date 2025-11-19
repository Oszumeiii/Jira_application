import 'package:injectable/injectable.dart';
import 'package:jira/core/api_client.dart';
import 'package:jira/features/dash_board/Issues/data/model/issue_model.dart';


abstract class IssueRemoteDataSource {
  Future<IssueModel> createIssue(IssueModel project);
   Future<List<IssueModel>> getIssuesByProject(String idProject);

  //Future<void> removeProject(String idProject);
}



@Injectable(as: IssueRemoteDataSource) 
class IssueRemoteDataSourceImpl implements IssueRemoteDataSource {
  @override
 @override
Future<IssueModel> createIssue(IssueModel issue) async {
  try {
    final response = await ApiClient.dio.post(
      '/issues',
      data: issue.toJson(),
    );

    if (response.data == null || response.data is! Map<String, dynamic>) {
      throw Exception("Invalid API response");
    }

    final jsonData = response.data as Map<String, dynamic>;
    final statusCode = jsonData['statusCode'] ?? 500;

    if (statusCode != 201) {
      final message = jsonData['message'] ?? "Unknown error";
      throw Exception("API Error: $message");
    }

    final data = jsonData['data'];
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception("API returned empty or invalid data");
    }

    return IssueModel.fromJson(data);
  } catch (e, s) {
    print("Error while creating issue: $e");
    print(s);
    rethrow; 
  }
}


  @override
Future<List<IssueModel>> getIssuesByProject(String idProject) async {
  try {
    print('Call getIssuesByProject');

    final response = await ApiClient.dio.get(
      '/issues',
      queryParameters: {'idProject': idProject},
    );

    print("Raw response: $response");
    print("Response data: ${response.data}");

    if (response.data == null || response.data is! Map<String, dynamic>) {
      print("API did not return valid JSON");
      return [];
    }

    final jsonData = response.data as Map<String, dynamic>;

    final int statusCode = jsonData['statusCode'] ?? 500;

    if (statusCode != 200) {
      print("API returned an error: ${jsonData['message']}");
      return [];
    }

    final dataList = (jsonData['data'] ?? []) as List<dynamic>;

    return dataList.map((e) => IssueModel.fromJson(e)).toList();

  } catch (e, s) {
    print("Error while calling API getIssuesByProject: $e");
    print(s);
    return [];
  }
}

}

