import 'package:injectable/injectable.dart';
import 'package:jira/core/api_client.dart';
import 'package:jira/features/dash_board/Issues/data/model/issue_model.dart';

abstract class IssueRemoteDataSource {
  Future<IssueModel> createIssue(IssueModel project);
   Future<List<IssueModel>> getIssuesByProject(String idProject);
   Future<IssueModel> updateIssue (IssueModel issue);
   Future<bool> deleteIssue (String idIssue);
   Future<List<IssueModel>> getIssueByUser(String idUser);
   
  //Future<void> removeProject(String idProject);
}



@Injectable(as: IssueRemoteDataSource) 
class IssueRemoteDataSourceImpl implements IssueRemoteDataSource {
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

    final statusCode = jsonData['statusCode'];
    if (statusCode != 201) {
      throw Exception("API Error: ${jsonData['message'] ?? 'Unknown error'}");
    }

    final data = jsonData['data']['issue'];
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception("API returned invalid or empty data");
    }
    return IssueModel.fromJson(data);

  } catch (e) {
    print("Error while creating issue: $e");
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

@override
Future<IssueModel> updateIssue(IssueModel issue) async {
  try {
    if (issue.id == null || issue.id!.isEmpty) {
      throw Exception("Missing issue id");
    }

  final response = await ApiClient.dio.put(
    '/issues/${issue.id}',
    data: issue.toJson(),
  );

    if (response.data == null || response.data is! Map<String, dynamic>) {
      throw Exception("Invalid API response");
    }

    final jsonData = response.data as Map<String, dynamic>;
    final statusCode = jsonData['statusCode'] ?? 500;

    if (statusCode != 200) {
      final message = jsonData['message'] ?? "Unknown update error";
      throw Exception("API Error: $message");
    }

    final data = jsonData['data'];
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception("API returned invalid updated data");
    }

    return IssueModel.fromJson(data);

  } catch (e, s) {
    print("Error while updating issue: $e");
    print(s);
    rethrow;
  }
}

@override
Future<bool> deleteIssue(String idIssue) async {
  try {
    if (idIssue.isEmpty) {
      throw Exception("Missing issue id");
    }
    final response = await ApiClient.dio.delete(
      '/issues/$idIssue',
    );

    final jsonData = response.data;
    if (jsonData == null || jsonData is! Map<String, dynamic>) {
      throw Exception("Invalid API response");
    }

    final statusCode = jsonData['statusCode'] ?? 500;
    if (statusCode != 200) {
      final message = jsonData['message'] ?? "Unknown delete error";
      throw Exception("API Error: $message");
    }
    return true;
  } catch (e, s) {
    print("Error while deleting issue: $e");
    print(s);
    return false; 
  }
}

  @override
  Future<List<IssueModel>> getIssueByUser(String userId) async {
    try {
    print('Call getIssuesByProject');

   final response = await ApiClient.dio.get(
      '/issues/assignee/$userId',
    );

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




