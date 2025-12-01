import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jira/core/injection.dart';
import 'package:jira/features/dash_board/Issues/presentation/cubit/issue_cubit.dart';
import 'package:jira/features/dash_board/projects/presentation/cubit/project_cubit.dart';
import 'package:jira/features/dash_board/projects/presentation/cubit/project_state.dart';
import 'package:jira/features/dash_board/Issues/presentation/board_project.dart';
import 'package:jira/features/dash_board/projects/presentation/view/project_info_page.dart';
import 'package:jira/features/login_signup/domain/cubit/AuthCubit.dart';
import '../../../../login_signup/presenation/widgets/project_row.dart';

class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectCubit, ProjectState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Operation successful!")),
          );
        } else if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: Colors.green.shade600,
            ),
          );
        }
      },
      builder: (context, state) {
        final projects = state.projects;
        final currentUid = getIt<AuthCubit>().state.uid; 

        if (state.isLoading && projects.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (projects.isEmpty) {
          return const Center(
            child: Text("No projects yet."),
          );
        }


        final myProjects = projects.where((p) => p.ownerId == currentUid).toList();
        final joinedProjects = projects.where((p) => p.ownerId != currentUid).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<ProjectCubit>().loadProjects();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                // const Text(
                //   "Projects",
                //   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                // ),
                // const SizedBox(height: 12),

                ExpansionTile(
                  title: Text("My Projects",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  initiallyExpanded: true,
                  children: myProjects.isEmpty
                      ? [const ListTile(title: Text("No projects created."))]
                      : myProjects.map((project) {
                          return GestureDetector(
                            child: ProjectRow(
                              name: project.name,
                              projectType: project.sumary!,
                              status: project.status,
                              onDetail: () {
                                final cubit = context.read<ProjectCubit>();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider.value(
                                      value: cubit,
                                      child: ProjectInfoPage(project: project),
                                    ),
                                  ),
                                );
                              },
                              onDelete: () async {
                                await context.read<ProjectCubit>().removeProject(project.id!);
                              },
                              
                            ),
                            onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                      create: (_) => getIt<IssueCubit>(),
                                      child: BoardProjectScreen(project: project),
                                    ),
                                  ),
                                );
                              },
                          );
                        }).toList(),
                ),

                const SizedBox(height: 8),

                ExpansionTile(
                  title: Text("Joined Projects",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  initiallyExpanded: false,
                  children: joinedProjects.isEmpty
                      ? [const ListTile(title: Text("No joined projects."))]
                      : joinedProjects.map((project) {
                          return GestureDetector(
                            child: ProjectRow(
                              name: project.name,
                              projectType: project.sumary!,
                              status: project.status,
                              onDetail: () {
                                final cubit = context.read<ProjectCubit>();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider.value(
                                      value: cubit,
                                      child: ProjectInfoPage(project: project),
                                    ),
                                  ),
                                );
                              },

                              onLeave: () async {
                                await context.read<ProjectCubit>().onLeaveProject(project , currentUid);
                              },
                            

                            //   if (context.mounted) {
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       const SnackBar(
                            //         content: Text("You have left the project"),
                            //         behavior: SnackBarBehavior.floating,
                            //       ),
                            //     );
                            //   }
                             
                              
                            ),

                            onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                      create: (_) => getIt<IssueCubit>(),
                                      child: BoardProjectScreen(project: project),
                                    ),
                                  ),
                                );
                              },
                          );
                        }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  
}
