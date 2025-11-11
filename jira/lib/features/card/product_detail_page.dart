// features/project_detail/presentation/project_detail_page.dart
import 'package:flutter/material.dart';
import 'package:jira/features/card/calendar_tab.dart';
import 'package:jira/features/card/stat_card.dart';
import 'package:jira/features/card/status_overview_card.dart';
import 'package:jira/features/card/todo_empty_card.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectName;

  const ProjectDetailPage({super.key, required this.projectName});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Mobile App",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          isScrollable: true,
          tabs: const [
            Tab(text: "Tóm tắt"),
            Tab(text: "Bảng thông tin"),
            Tab(text: "Lịch"),
            Tab(text: "Biểu mẫu"),
            Tab(text: "Lịch trình"),
            Tab(text: "Cài đặt"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(),
          _buildBoardTab(),
          _buildCalendarTab(),
          _buildFormsTab(),
          _buildTimelineTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            StatCard(
              icon: Icons.check_circle,
              count: 0,
              label: "Đã hoàn thành\ntrong 7 ngày qua",
            ),
            const SizedBox(width: 12),
            StatCard(
              icon: Icons.update,
              count: 0,
              label: "Đã cập nhật\ntrong 7 ngày qua",
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            StatCard(
              icon: Icons.add_circle,
              count: 0,
              label: "Đã tạo\ntrong 7 ngày qua",
            ),
            const SizedBox(width: 12),
            StatCard(
              icon: Icons.schedule,
              count: 0,
              label: "0 đến hạn\ntrong 7 ngày tới",
            ),
          ],
        ),
        const SizedBox(height: 24),
        const StatusOverviewCard(),
      ],
    );
  }

  Widget _buildBoardTab() {
    return const TodoEmptyCard();
  }

  Widget _buildCalendarTab() {
    return const CalendarTab();
  }

  Widget _buildFormsTab() {
    return const Center(
      child: Text(
        "Chưa có biểu mẫu\nTruy cập Jira trên Web để tạo biểu mẫu mới.",
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimelineTab() {
    return const Center(
      child: Text(
        "Lập kế hoạch cho công việc cấp cao\nTạo hạng mục công việc để điền vào\nLịch trình của nhóm",
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.image),
          title: const Text("Thay đổi hình đại diện"),
          onTap: () {},
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              labelText: "Tên không gian",
              hintText: "Mobile App",
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              labelText: "Mã không gian",
              hintText: "MA",
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text("Tính năng"),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "Chuyển không gian vào thùng rác",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
