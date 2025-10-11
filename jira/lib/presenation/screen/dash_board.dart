import 'package:flutter/material.dart';
import 'package:jira/presenation/widgets/project_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _tabs = ['Projects', 'Tasks', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabs[_selectedIndex]),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _ProjectsTab(),
          _TasksTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.work_outline), label: 'Projects'),
          NavigationDestination(icon: Icon(Icons.task_outlined), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  const _ProjectsTab();

  @override
  Widget build(BuildContext context) {
    // sau này sẽ dùng BlocBuilder<ProjectCubit> ở đây
    final mockProjects = [
      {'name': 'Jira App MVP', 'description': 'Build CI/CD + Firebase + Flutter'},
      {'name': 'AI Agent Tool', 'description': 'Integrate LLM to manage tasks'},
      {'name': 'Bug Tracker', 'description': 'Simple issue tracker for internal devs'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: mockProjects.length,
        itemBuilder: (context, index) {
          final project = mockProjects[index];
          return ProjectCard(
            name: project['name']!,
            description: project['description']!,
          );
        },
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  const _TasksTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Task list will appear here"),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Profile info will appear here"),
    );
  }
}
