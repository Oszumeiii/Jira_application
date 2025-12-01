import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/core/api_client.dart';
import 'package:jira/core/injection.dart';
import 'package:jira/features/dash_board/Issues/data/model/issue_model.dart';
import 'package:jira/features/dash_board/Issues/domain/Usecase/get_issue_by_project_usecase.dart';
import 'package:jira/features/dash_board/Issues/presentation/widget/task_today_card.dart';
import 'package:jira/features/dash_board/presentation/add_project_page.dart';
import 'package:jira/features/dash_board/projects/presentation/cubit/project_cubit.dart';
import 'package:jira/features/dash_board/projects/presentation/cubit/project_state.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<List<IssueModel>> _tasksTodayFuture;

  @override
  void initState() {
    super.initState();
    //context.read<ProjectCubit>().loadProjects();
    _tasksTodayFuture = _loadTasksToday();
  }

  void _showBottomSheetAddProject() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddProjectBottomSheet(),
    ).then((_) {
      context.read<ProjectCubit>().loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HELLO USER
            Text(
              "Let's make today productive! 💼",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/groupworking_img.jpg'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          FutureBuilder<List<IssueModel>>(
            future: _tasksTodayFuture,
            builder: (context, snapshot) {
              final tasks = snapshot.data ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Let's crush today's tasks! 💪",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (tasks.isEmpty)
                    const Text(
                      "No tasks for today !",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return TaskTodayCard(task: tasks[index]);
                      },
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 10),
          /// PROJECT PROGRESS SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle("Project Progress"),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF19183B),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF19183B).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _showBottomSheetAddProject,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          /// PROJECT LIST
          BlocBuilder<ProjectCubit, ProjectState>(
  builder: (context, state) {
    final projects = state.projects;

    if (state.isLoading && projects.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (projects.isEmpty) {
      return const Center(child: Text("No projects available"));
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final project = projects[index];

        return FutureBuilder<double>(
          future: getProjectProgress(project.id!),
          builder: (context, snapshot) {
            final progress = snapshot.data ?? 0.0; 
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ProjectCard(
                name: project.name,
                description: project.sumary ?? '',
                progress: progress,
              ),
            );
          },
        );
      },
    );
  },
)
        ],
      ),
    );
  }

  /// Helper for section title
  Widget _sectionTitle(String title, {int? count}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<List<IssueModel>> _loadTasksToday() async {
    try {
      final response = await ApiClient.dio.get("/issues/assignee");

      if (response.statusCode != 200) {
        print("API error: ${response.statusCode}");
        return [];
      }

      final data = response.data['data'] as List<dynamic>;
      final tasks = data.map((e) => IssueModel.fromJson(e)).toList();

      return tasks.where((task) => task.status.toLowerCase() != "done").toList();
    } catch (e) {
      return [];
    }
  }

  Future<double> getProjectProgress(String projectId) async {
    try {
      final getIssueUsecase = getIt<GetIssueByProjectUsecase>();
      final issues = await getIssueUsecase.call(projectId);

      if (issues.isEmpty) return 0.0;

      final completed = issues.where((issue) => issue.status.toLowerCase() == 'done').length;
      return completed / issues.length;
    } catch (e) {
      return 0.0;
    }
  }
}


class ProjectCard extends StatelessWidget {
  final String name;
  final String description;
  final double progress;

  const ProjectCard({
    super.key,
    required this.name,
    required this.description,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final double cardHeight = 80; 
    final double cardWidth = MediaQuery.of(context).size.width; 
    final double aspectRatio = 3; 

    return Container(
      width: cardWidth,
      height: cardWidth / aspectRatio,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 0, 41, 87),
            Colors.blue[900]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[900]!.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.3),
            color: Colors.greenAccent,
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).round()}% completed',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
