import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jira/features/dash_board/presentation/add_project_page.dart';
import 'package:jira/features/dash_board/presentation/profile/profile.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat_tab.dart';
import 'package:jira/features/dash_board/presentation/tab/home_tab.dart';
import 'package:jira/features/dash_board/presentation/tab/notif_tab.dart';
import 'package:jira/features/dash_board/projects/domain/entities/project_entity.dart';
import 'package:jira/features/dash_board/projects/presentation/cubit/project_cubit.dart';
import 'package:jira/features/dash_board/projects/presentation/view/projects_tab.dart';
import 'package:jira/features/dash_board/presentation/tab/task_tab.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['Home', 'Projects', 'Tasks', 'Chat'];
  final List<Widget> _tabBodies = [
    HomeTab(),
    ProjectsTab(),
    TasksTab(),
    ChatTab(),
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectCubit>().loadProjects();
    });
  }

  void _showBottomSheetAddProject() async {
    final project = await showModalBottomSheet<ProjectEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddProjectBottomSheet(),
    );

    if (project != null) {
      context
          .read<ProjectCubit>()
          .createProject(project)
          .then((_) {
              ScaffoldMessenger.of(
                            context,
                          ).showSnackBar( SnackBar(
                      content: const Text("Project created Sucessfully !"),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: const Color.fromARGB(255, 0, 52, 137),
                    ),);
          })
          .catchError((e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar( SnackBar(
        content: const Text("Error !"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.green.shade600,
      ),);

          });
    }
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onCreatePressed() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_task),
              title: const Text('New task'),
              onTap: () {
                Navigator.pop(context);
                // Thêm logic tạo task
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_special),
              title: const Text('New project'),
              onTap: () {
                Navigator.pop(context);
                _showBottomSheetAddProject();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        title: Text(
          _tabs[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        backgroundColor: const Color(0xFFF5F5F0),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotifTab()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _tabBodies),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home_outlined, 'Home', 0),
                      _buildNavItem(Icons.task_outlined, 'Projects', 1),
                      _buildCenterButton(),
                      _buildNavItem(Icons.checklist_rtl_outlined, 'Tasks', 2),
                      _buildNavItem(Icons.chat_bubble, 'Chat', 3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onTabSelected(index),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF0052CC) : Colors.grey,
                size: isSelected ? 28 : 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? const Color(0xFF0052CC) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: FloatingActionButton(
        onPressed: _onCreatePressed,
        backgroundColor: const Color(0xFF0052CC),
        elevation: 5,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}
