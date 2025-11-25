import 'package:flutter/material.dart';

class ProjectRow extends StatelessWidget {
  final String name;
  final String projectType;
  final String? status;
  final VoidCallback? onDetail;
  final VoidCallback? onDelete;

  const ProjectRow({
    super.key,
    required this.name,
    required this.projectType,
    this.status,
    this.onDetail,
    this.onDelete,
  });

  Color _getStatusColor() {
    switch (status?.toLowerCase()) {
      case "active":
        return Colors.greenAccent;
      case "pending":
        return Colors.orangeAccent;
      case "completed":
        return Colors.lightBlueAccent;
      default:
        return Colors.grey[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double rowWidth = MediaQuery.of(context).size.width - 32;

    return Container(
      width: rowWidth,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 0, 41, 87),
            Colors.blue[900]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[900]!.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
                color: _getStatusColor(),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor().withOpacity(0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),

          // Name + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  projectType,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: null,
                  softWrap: true,
                ),
              ],
            ),
          ),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onDetail != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.white,
                    ),
                    onPressed: onDetail,
                    tooltip: 'Project Detail',
                    splashRadius: 20,
                  ),
                ),

                const SizedBox(width: 8),
            if (onDelete != null)
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 249, 248).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.white, // icon màu trắng
                    ),
                    tooltip: 'Delete project',
                    splashRadius: 20,
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: const Color.fromARGB(255, 30, 30, 30), // nền dark
                          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 48, color: Color.fromARGB(255, 255, 0, 4)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Remove Project',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 255, 255), // text màu trắng
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Are you sure you want to remove this project? This action cannot be undone.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, color: Colors.white70), // text màu trắng nhạt
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        side: const BorderSide(color: Colors.white70),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.white), // text trắng
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        child: Text(
                                          'Remove',
                                          style: TextStyle(color: Colors.white), // text trắng
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );

                      if (confirmed == true) {
                        onDelete!();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Project removed successfully!",
                              style: TextStyle(color: Colors.white), // text trắng
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.red.shade700,
                          ),
                        );
                      }
                    },
                  ),
                ),


            ],
          ),
        ],
      ),
    );
  }
}