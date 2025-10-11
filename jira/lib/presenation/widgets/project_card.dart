import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final String name;
  final String description;

  const ProjectCard({
    super.key,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.work_outline, color: Colors.deepPurple),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 18),
          onPressed: () {},
        ),
      ),
    );
  }
}
