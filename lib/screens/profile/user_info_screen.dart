import 'package:flutter/material.dart';

import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_toast.dart';
import '../admin/admin_mchat_question_screen.dart';
import '../admin/admin_screening_stats_screen.dart';
import '../admin/admin_user_management_screen.dart';
import '../admin/admin_user_stats_screen.dart';
import '../auth/login_screen.dart';
import 'change_password_screen.dart';
import 'parent_info_screen.dart';

class UserInfoScreen extends StatefulWidget {
  final UserModel user;

  const UserInfoScreen({super.key, required this.user});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final UserController _controller = UserController();
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    AppToast.show(context, 'Đã đăng xuất thành công');
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 40,
              child: Text(
                user.fullName.isNotEmpty ? user.fullName.substring(0, 1) : '?',
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.fullName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(user.email),

            const SizedBox(height: 24),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Thông tin phụ huynh'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final updatedUser = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ParentInfoScreen(user: user),
                  ),
                );
                if (updatedUser != null) {
                  setState(() => user = updatedUser);
                  Navigator.pop(context, updatedUser);
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Đổi mật khẩu'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangePasswordScreen(userId: user.id),
                ),
              ),
            ),

            if (user.role == 'ADMIN') ...[
              const Divider(height: 24),

              ListTile(
                leading: const Icon(Icons.fact_check, color: Colors.deepPurple),
                title: const Text('Quản lý câu hỏi M-CHAT'),
                subtitle: const Text('Xem & chỉnh sửa câu hỏi'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminMchatQuestionScreen(),
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.teal,
                ),
                title: const Text('Quản lý tài khoản người dùng'),
                subtitle: const Text('Role, khóa, xóa tài khoản'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUserManagementScreen(),
                  ),
                ),
              ),

              const Divider(height: 8),

              ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.indigo),
                title: const Text('Thống kê kết quả sàng lọc'),
                subtitle: const Text('Biểu đồ nguy cơ cao/TB/thấp'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminScreeningStatsScreen(),
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.people_alt, color: Colors.indigo),
                title: const Text('Thống kê chi tiết người dùng'),
                subtitle: const Text('Số lần sàng lọc, hồ sơ trẻ'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUserStatsScreen(),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
