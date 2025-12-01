import 'package:dio/dio.dart';
import 'package:jira/core/api_client.dart';

class NotificationService {

  // Thêm member vào project
  Future<void> addMember({
    required String addedUserId,
    required String projectName,
    required String token, // token verify
  }) async {
    try {
      await ApiClient.dio.post(
        '/notify',
        data: {
          'addedUserId': addedUserId,
          'projectName': projectName,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to add member notification: $e');
    }
  }

  // Assign task cho member
  Future<void> assignTask({
    required String assignedUserId,
    required String taskTitle,
    required String token,
  }) async {
    try {
      await ApiClient.dio.post(
        'https://your-api-domain.com/api/notify/assign',
        data: {
          'assignedUserId': assignedUserId,
          'taskTitle': taskTitle,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to assign task notification: $e');
    }
  }


  Future<void> commentTask({
    required String taskOwnerId,
    required String taskTitle,
    required String token,
  }) async {
    try {
      await ApiClient.dio.post(
        'https://your-api-domain.com/api/notify/comment',
        data: {
          'taskOwnerId': taskOwnerId,
          'taskTitle': taskTitle,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to comment task notification: $e');
    }
  }
}
