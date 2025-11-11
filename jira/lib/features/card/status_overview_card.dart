// features/project_detail/presentation/widgets/status_overview_card.dart
import 'package:flutter/material.dart';

class StatusOverviewCard extends StatelessWidget {
  const StatusOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tổng quan về trạng thái\ntrong 14 ngày qua",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "0",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
          ),
          const Center(
            child: Text(
              "Hạng mục công việc",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          _buildStatusRow("To Do", Colors.grey, 0),
          _buildStatusRow("In Progress", Colors.blue, 0),
          _buildStatusRow("Done", Colors.green, 0),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(radius: 6, backgroundColor: color),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Text("$count >", style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }
}
