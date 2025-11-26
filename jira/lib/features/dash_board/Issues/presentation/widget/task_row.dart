import 'package:jira/features/dash_board/Issues/domain/Entity/issue_entity.dart';
import 'package:flutter/material.dart';

class TaskRow extends StatelessWidget {
  final IssueEntity task;
  final Function(String)? onStatusChanged;

   TaskRow({
    super.key,
    required this.task,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getPriorityColors(task.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
      color: const Color(0xFFFDFDFE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromARGB(255, 255, 255, 255), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEFT PRIORITY BAR
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: colors['accent'],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),

          /// MAIN CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ---------- TYPE & TITLE ----------
                Row(
                  children: [
                    _buildTypeBadge(task.type),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// ---------- DATE + STATUS ----------
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(task.createdAt),
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),

                    const Spacer(),

                    _buildStatusDropdown(task.status),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  //══════════════════════════════════════════════════════════════════════════
  // TYPE BADGE
  //══════════════════════════════════════════════════════════════════════════

  Widget _buildTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  //══════════════════════════════════════════════════════════════════════════
  // DATE FORMAT
  //══════════════════════════════════════════════════════════════════════════

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';

    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return "Today";
    if (diff == 1) return "Yesterday";
    if (diff < 7) return "$diff days ago";

    return "${date.day}/${date.month}/${date.year}";
  }

  //══════════════════════════════════════════════════════════════════════════
  // PRIORITY COLORS
  //══════════════════════════════════════════════════════════════════════════

  Map<String, Color> _getPriorityColors(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return {"accent": const Color(0xFFE11D48)}; // red-600
      case "medium":
        return {"accent": const Color(0xFFF59E0B)}; // amber-500
      default:
        return {"accent": const Color(0xFF10B981)}; // emerald-500
    }
  }

  //══════════════════════════════════════════════════════════════════════════
  // STATUS DROPDOWN
  //══════════════════════════════════════════════════════════════════════════

  Widget _buildStatusDropdown(String status) {
    final data = _getStatusData(status);

    return PopupMenuButton<String>(
      onSelected: (String selectedText) {
        final newStatus = _reverseStatusMap[selectedText]!;
        onStatusChanged?.call(newStatus);
      },
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 4,
      itemBuilder: (_) => [
        _menu("To Do", Icons.check_box_outline_blank, Colors.grey.shade700),
        _menu("In Progress", Icons.autorenew_rounded, const Color(0xFFF59E0B)),
        _menu("Done", Icons.check_circle_rounded, const Color(0xFF3B82F6)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: data["bg"],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(data["icon"], size: 16, color: data["color"]),
            const SizedBox(width: 6),
            Text(
              data["label"],
              style: TextStyle(
                color: data["color"],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: data["color"]),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menu(String label, IconData icon, Color color) {
    return PopupMenuItem(
      value: label,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  //══════════════════════════════════════════════════════════════════════════
  // STATUS MAP
  //══════════════════════════════════════════════════════════════════════════

  final Map<String, dynamic> _statusMap = {
    "todo": {
      "label": "To Do",
      "color": Color(0xFF6B7280),
      "bg": Color(0xFFF3F4F6),
      "icon": Icons.check_box_outline_blank,
    },
    "inprogress": {
      "label": "In Progress",
      "color": Color(0xFFF59E0B),
      "bg": Color(0xFFFEF3C7),
      "icon": Icons.autorenew_rounded,
    },
    "done": {
      "label": "Done",
      "color": Color(0xFF3B82F6),
      "bg": Color(0xFFEFF6FF),
      "icon": Icons.check_circle_rounded,
    },
  };

  Map<String, dynamic> _getStatusData(String status) {
    return _statusMap[status.toLowerCase()] ??
        _statusMap["todo"]!;
  }

  final Map<String, String> _reverseStatusMap = const {
    "To Do": "todo",
    "In Progress": "inProgress",
    "Done": "done",
  };
}
