import 'package:flutter/material.dart';
import 'package:jira/core/api_client.dart';
import 'package:jira/core/injection.dart';
import 'package:jira/features/dash_board/Issues/data/model/issue_model.dart';
import 'package:jira/features/dash_board/Issues/domain/Usecase/update_issue_usecase.dart';
import 'package:jira/features/dash_board/Issues/presentation/view/detail_task_page.dart';
import 'package:jira/features/dash_board/Issues/presentation/widget/task_row.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => TasksTabState();
}

class TasksTabState extends State<TasksTab> {
  late Future<List<IssueModel>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = fetchTasks();
  }

  Future<void> refreshTasks() async {
    setState(() {
      _tasksFuture = fetchTasks();
    });
  }

  Future<List<IssueModel>> fetchTasks() async {
    try {
      final response = await ApiClient.dio.get("/issues/assignee");

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data.map((e) => IssueModel.fromJson(e)).toList();
      } else {
        print("API error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }

  Future<void> changeStatus(IssueModel task, String newStatus) async {
    try {
      final updateIssueUsecase = getIt<UpdateIssueUsecase>();

      final updatedIssue = await updateIssueUsecase.call(
        task.copyWith(status: newStatus),
      );
      await refreshTasks();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Task '${updatedIssue.title}' updated to '$newStatus'"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating task"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<IssueModel>>(
      future: _tasksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No tasks assigned to you",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        } else {
          final tasks = snapshot.data!;
          return RefreshIndicator(
            onRefresh: refreshTasks,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                  final task = tasks[index];
                  return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailTaskPage(issue: task),
                          ),
                        );
                        refreshTasks();
                      },

                    child: TaskRow(
                      task: task,
                      onStatusChanged: (newStatus) {
                        changeStatus(task, newStatus);
                      },
                    ),
                  );
                }

            ),
          );
        }
      },
    );
  }
}
