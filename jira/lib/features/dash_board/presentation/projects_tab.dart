// projects_tab.dart
import 'package:flutter/material.dart';
import '../../widgets/project_card.dart';

class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final mockProjects = [
      {
        'name': 'Jira App MVP',
        'description': 'Build CI/CD + Firebase + Flutter',
      },
      {'name': 'AI Agent Tool', 'description': 'Integrate LLM to manage tasks'},
      {'name': 'Bug Tracker', 'description': 'Simple issue tracker for internal devs'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Projects",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mockProjects.length,
              itemBuilder: (context, index) {
                final project = mockProjects[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ProjectCard(
                    name: project['name']!,
                    description: project['description']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
