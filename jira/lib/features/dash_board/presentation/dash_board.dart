import 'package:flutter/material.dart';
import 'package:jira/features/dash_board/presentation/home_tab.dart';
import 'package:jira/features/dash_board/presentation/notif_tab.dart';
import 'package:jira/features/dash_board/presentation/profile/profile.dart';
import 'package:jira/features/dash_board/presentation/projects_tab.dart';
import 'package:jira/features/dash_board/presentation/task_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _tabs = ['Home', 'Projects', 'Tasks', 'Notification'];

  final List<Widget> _tabBodies = const [
    HomeTab(),
    ProjectsTab(),
    TasksTab(),
    NotifTab(),
  ];

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
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
      body: IndexedStack(index: _selectedIndex, children: _tabBodies),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rtl_outlined),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
        ],
        onDestinationSelected: _onTabSelected,
      ),
    );
  }
}
