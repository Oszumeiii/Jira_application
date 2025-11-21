import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/dash_board/Issues/domain/Entity/issue_entity.dart';
import 'package:jira/features/dash_board/Issues/presentation/cubit/issue_cubit.dart';
import 'package:jira/features/dash_board/Issues/presentation/cubit/issue_state.dart';
import 'package:jira/features/dash_board/Issues/presentation/view/add_issue_bottomsheet.dart';
import 'package:jira/features/dash_board/Issues/presentation/view/detail_issue_page.dart';
import 'package:jira/features/dash_board/projects/domain/entities/project_entity.dart';

class ProjectDetailPage extends StatefulWidget {
  final ProjectEntity project ; 

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<IssueCubit>().loadIssuesByProject(widget.project.id!);
  }

  Widget taskItem(IssueEntity issue, Color color) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<IssueCubit>(),
            child: DetailIssuePage(issue: issue),
          ),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              issue.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    ),
  );
}


  //bottomsheet add issue
  void _showBottomSheetAddIssue(String projectId) async {
      final newIssue = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddIssueBottomsheet(project: widget.project),
      );
      if (newIssue != null) {
        context.read<IssueCubit>().addIssue(newIssue);
      }
  }


  Widget buildTasks(List<IssueEntity> tasks, Color color) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          "No tasks yet",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return taskItem(tasks[index], color);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        title: const Text(
          "Board",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "To Do"),
            Tab(text: "In Progress"),
            Tab(text: "Done"),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
        onPressed: () {
          _showBottomSheetAddIssue(widget.project.id!);
        },
      ),

      body: BlocBuilder<IssueCubit, IssueState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              buildTasks(state.todo, const Color.fromARGB(255, 255, 0, 0)),
              buildTasks(state.inProgress, const Color.fromARGB(255, 0, 140, 255)),
              buildTasks(state.done, const Color.fromARGB(255, 0, 255, 8)),
            ],
          );
        },
      ),
    );
  }
}
