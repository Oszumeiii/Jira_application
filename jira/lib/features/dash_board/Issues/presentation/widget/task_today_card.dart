import 'package:flutter/material.dart';
import 'package:jira/features/dash_board/Issues/data/model/issue_model.dart';

class TaskTodayCard extends StatelessWidget {
  final IssueModel task;

  const TaskTodayCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal : 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF19183B),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type + Title
            Row(
              children: [
                _buildTypeBadge(task.type),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
      
            const SizedBox(height: 10),
      
            // Status label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.status,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Type badge
  Widget _buildTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: Colors.blue.shade200,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
