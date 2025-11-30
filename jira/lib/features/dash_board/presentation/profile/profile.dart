import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jira/core/injection.dart';
import 'package:jira/features/dash_board/presentation/profile/cubit/profile_cubit.dart';
import 'package:jira/features/dash_board/presentation/profile/cubit/profile_state.dart';
import 'dart:io';

import 'package:jira/features/login_signup/domain/cubit/AuthCubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..loadCurrentUser(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        const Color primaryBlue = Color(0xFF0052CC);
        const Color lightBlue = Color(0xFFE8F1FF);
        const Color bgColor = Color(0xFFF7F9FC);

        // Loading
        if (state.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error
        if (state.error != null) {
          return Scaffold(body: Center(child: Text(state.error!)));
        }

        // Dữ liệu user
        final user = state.userData!;

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                // ===== Header với gradient xanh mượt =====
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0065FF), Color(0xFF2684FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Column(
                    children: [
                      // Nút quay lại
                      Align(
                        alignment: Alignment.topLeft,
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Avatar với nút chỉnh sửa
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(48),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              backgroundImage: user['photoURL'] != null
                                  ? NetworkImage(user['photoURL'])
                                  : null,
                              child: user['photoURL'] == null
                                  ? Text(
                                      (user['firstName']?[0] ?? '') +
                                          (user['lastName']?[0] ?? ''),
                                      style: const TextStyle(
                                        color: primaryBlue,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showAvatarEditDialog(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Tên với nút chỉnh sửa
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${user['firstName']} ${user['lastName']}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showEditNameDialog(context),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${user['email']}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Domain badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: ShapeDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                              color: Colors.white,
                              width: 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.language, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "huanhung.atlassian.net",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ===== Menu Section =====
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        children: [
                          _MenuItem(
                            icon: Icons.notifications_none_rounded,
                            title: "Notification settings",
                            onTap: () {},
                          ),
                          _MenuItem(
                            icon: Icons.settings_outlined,
                            title: "Settings",
                            onTap: () {},
                          ),
                          Divider(color: Colors.grey.shade200),
                          _MenuItem(
                            icon: Icons.person_add_alt_1_outlined,
                            title: "Invite team members",
                            onTap: () {},
                          ),
                          _MenuItem(
                            icon: Icons.feedback_outlined,
                            title: "Send feedback",
                            onTap: () {},
                          ),
                          _MenuItem(
                            icon: Icons.apps_rounded,
                            title: "More Atlassian apps",
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      getIt<AuthCubit>().logout();
                      context.go('/login');
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0065FF), Color(0xFF2684FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Log out",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final state = cubit.state;
    final user = state.userData!;

    final firstNameController = TextEditingController(
      text: user['firstName'] ?? '',
    );
    final lastNameController = TextEditingController(
      text: user['lastName'] ?? '',
    );
    final userNameController = TextEditingController(
      text: user['userName'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'Họ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Tên',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: userNameController,
                decoration: InputDecoration(
                  labelText: 'Tên người dùng',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.alternate_email),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await cubit.updateProfile(
                firstName: firstNameController.text.trim(),
                lastName: lastNameController.text.trim(),
                userName: userNameController.text.trim(),
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã cập nhật thông tin'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0065FF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showAvatarEditDialog(BuildContext context) {
    final cubit = context
        .read<ProfileCubit>(); // Lấy cubit ở đây, trước khi mở bottom sheet

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                await _pickAndUploadImage(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                await _pickAndUploadImage(context, ImageSource.camera);
              },
            ),
            if (cubit.state.userData?['photoURL'] != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Xóa ảnh đại diện',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);
                  await cubit.updateProfile(photoURL: '');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa ảnh đại diện'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(
    BuildContext context,
    ImageSource source,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không chọn được ảnh'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final file = File(image.path);
      final cubit = context.read<ProfileCubit>();

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final url = await cubit.uploadAvatar(file);

      if (context.mounted) {
        Navigator.pop(context); // Đóng loading

        if (url != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật ảnh đại diện'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(cubit.state.error ?? 'Lỗi upload ảnh'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on UnsupportedError {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Không hỗ trợ chọn ảnh trên thiết bị mô phỏng. '
              'Vui lòng dùng thiết bị thật hoặc thêm ảnh vào thư viện.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0052CC);
    const Color lightBlue = Color(0xFFE8F1FF);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
