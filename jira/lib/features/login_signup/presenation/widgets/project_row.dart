import 'package:flutter/material.dart';

class ProjectRow extends StatelessWidget {
  final String name;
  final String projectType;
  final String? status;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProjectRow({
    super.key,
    required this.name,
    required this.projectType,
    this.status,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double rowHeight = 80; // increased height for wrapping
    final double rowWidth = MediaQuery.of(context).size.width - 32; // full width minus padding

    return Container(
      width: rowWidth,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          if (status != null)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 12, top: 4),
              decoration: BoxDecoration(
                color: status == "active" ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),

          // Name + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  projectType,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: null, 
                  softWrap: true,
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // if (onEdit != null)
              //   IconButton(
              //     icon: const Icon(Icons.edit, size: 20),
              //     onPressed: onEdit,
              //     tooltip: 'Edit project',
              //   ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                  tooltip: 'Delete project',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
