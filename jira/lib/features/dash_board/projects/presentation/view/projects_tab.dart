import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/features/dash_board/projects/presentation/cubit/project_state.dart';
import '../../../../login_signup/presenation/widgets/project_card.dart';
import '../../../projects/presentation/cubit/project_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectCubit, ProjectState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              "${state.errorMessage}1",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final projects = state.projects;
        if (projects.isEmpty) {
          return const Center(child: Text("No projects yet."));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "My Projects",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: ProjectCard(
                        name: project.name,
                        description: project.description ?? "",
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
