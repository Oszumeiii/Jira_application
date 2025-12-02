import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/core/api_client.dart';
import 'package:jira/features/dash_board/Issues/data/model/issue_model.dart';

class TaskTodayCubit extends Cubit<Stream<List<IssueModel>>> {

  TaskTodayCubit() : super(const Stream.empty());

  void start() {
    emit(Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => _loadTasksToday()));
  }

  Future<List<IssueModel>> _loadTasksToday() async {
    try {
      final res = await ApiClient.dio.get("/issues/assignee");
      final data = (res.data['data'] as List)
          .map((e) => IssueModel.fromJson(e))
          .toList();

      return data.where((t) => t.status.toLowerCase() != "done").toList();
    } catch (_) {
      return [];
    }
  }
}
