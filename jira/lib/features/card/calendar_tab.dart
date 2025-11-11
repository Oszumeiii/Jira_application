// features/project_detail/presentation/widgets/calendar_tab.dart
import 'package:flutter/material.dart';

class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            DropdownButton<String>(
              value: "Trạng thái",
              items: [
                "Trạng thái",
                "Ưu tiên",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (_) {},
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: "Người được chỉ định",
              items: [
                "Người được chỉ định",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (_) {},
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: "Mức ưu tiên",
              items: [
                "Mức ưu tiên",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (_) {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "tháng 11 2025",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text("Hôm nay", style: TextStyle(color: Colors.blue)),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          children: [
            TableRow(
              children: ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
                  .map(
                    (e) => Center(
                      child: Text(
                        e,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                  .toList(),
            ),
            ..._buildCalendarRows(),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "Chưa được lên lịch (0)",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  List<TableRow> _buildCalendarRows() {
    final days = [
      [27, 28, 29, 30, 31, 1, 2],
      [3, 4, 5, 6, 7, 8, 9],
      [10, 11, 12, 13, 14, 15, 16],
      [17, 18, 19, 20, 21, 22, 23],
      [24, 25, 26, 27, 28, 29, 30],
    ];

    return days.map((week) {
      return TableRow(
        children: week.map((day) {
          final isToday = day == 11;
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isToday ? Colors.blue : null,
              shape: BoxShape.circle,
            ),
            child: Text(
              "$day",
              style: TextStyle(
                color: isToday ? Colors.white : Colors.black,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      );
    }).toList();
  }
}
