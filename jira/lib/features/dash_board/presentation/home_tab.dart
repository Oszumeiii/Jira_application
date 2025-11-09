import 'package:flutter/material.dart';
import 'package:jira/presenation/screen/dashboard/add_project_page.dart';
import 'package:jira/presenation/widgets/note_card.dart';
import 'package:jira/presenation/widgets/project_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  void _showBottomSheetAddProject() {
        showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const AddProjectBottomSheet(),
      );

  }

  @override
  Widget build(BuildContext context) {
    final mockProjects = [
      {
        'name': 'Jira App MVP',
        'description': 'Build CI/CD + Firebase + Flutter',
      },
      {'name': 'AI Agent Tool', 'description': 'Integrate LLM to manage tasks'},
      {
        'name': 'Bug Tracker',
        'description': 'Simple issue tracker for internal devs',
      },
    ];

    final notes = [
      {
        'name': 'Huấn',
        'avatar': 'https://i.pravatar.cc/150?img=3',
        'note':
            'Hôm nay trời đẹp quá!',
      },
      {
        'name': 'Lan',
        'avatar': 'https://i.pravatar.cc/150?img=5',
        'note': 'Đã hoàn thành bài tập Flutter 😄',
      },
      {
        'name': 'Minh',
        'avatar': 'https://i.pravatar.cc/150?img=8',
        'note': 'Cuối tuần đi Đà Nẵng thôi!',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search projects, tasks, or notes...",
                border: InputBorder.none,
              ),
              onChanged: (query) {
                // TODO: thêm logic tìm kiếm sau
                print("Searching: $query");
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.grey),
            onPressed: () {
              // TODO: mở modal filter
            },
          ),
        ],
      ),
    ),
          const Text(
            "Notes ...",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

         SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return  NoteCard(
                      avatar: note['avatar']!,
                      name: note['name']!,
                      note: note['note']!,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
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

          Padding(
            padding: const EdgeInsets.only(top: 10, left: 4, right: 4, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Projects",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E2E2E),
                    letterSpacing: 0.5,
                  ),
                ),
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
                    onPressed: _showBottomSheetAddProject
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: mockProjects.length,
              scrollDirection: Axis.horizontal,
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

