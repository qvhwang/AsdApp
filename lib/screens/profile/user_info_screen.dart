import 'package:flutter/material.dart';

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
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Đăng xuất?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
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
    final initials = user.fullName.trim().isNotEmpty
        ? user.fullName.trim().split(' ').last.substring(0, 1).toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.teal,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00695C), Color(0xFF26A69A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 2.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: user.role == 'ADMIN'
                              ? Colors.amber.withOpacity(0.25)
                              : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          user.role == 'ADMIN' ? '👑 Admin' : '👤 Phụ huynh',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Tài khoản'),
                  const SizedBox(height: 8),
                  _menuCard(
                    children: [
                      _menuItem(
                        icon: Icons.person_outline,
                        color: Colors.teal,
                        title: 'Thông tin phụ huynh',
                        subtitle: 'Chỉnh sửa họ tên',
                        onTap: () async {
                          final updatedUser = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ParentInfoScreen(user: user),
                            ),
                          );
                          if (updatedUser != null) {
                            setState(() => user = updatedUser);
                            if (mounted) Navigator.pop(context, updatedUser);
                          }
                        },
                      ),
                      _divider(),
                      _menuItem(
                        icon: Icons.lock_outline,
                        color: Colors.indigo,
                        title: 'Đổi mật khẩu',
                        subtitle: 'Cập nhật mật khẩu mới',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChangePasswordScreen(userId: user.id),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ADMIN SECTION
                  if (user.role == 'ADMIN') ...[
                    const SizedBox(height: 20),
                    _sectionTitle('Quản trị'),
                    const SizedBox(height: 8),
                    _menuCard(
                      children: [
                        _menuItem(
                          icon: Icons.fact_check_outlined,
                          color: Colors.deepPurple,
                          title: 'Quản lý câu hỏi M-CHAT',
                          subtitle: 'Xem & chỉnh sửa câu hỏi',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminMchatQuestionScreen(),
                            ),
                          ),
                        ),
                        _divider(),
                        _menuItem(
                          icon: Icons.manage_accounts_outlined,
                          color: Colors.teal,
                          title: 'Quản lý tài khoản',
                          subtitle: 'Role, khóa, xóa tài khoản',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminUserManagementScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    _menuCard(
                      children: [
                        _menuItem(
                          icon: Icons.bar_chart_rounded,
                          color: Colors.orange,
                          title: 'Thống kê kết quả sàng lọc',
                          subtitle: 'Biểu đồ nguy cơ cao/TB/thấp',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminScreeningStatsScreen(),
                            ),
                          ),
                        ),
                        _divider(),
                        _menuItem(
                          icon: Icons.people_alt_outlined,
                          color: Colors.blue,
                          title: 'Thống kê người dùng',
                          subtitle: 'Số lần sàng lọc, hồ sơ trẻ',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminUserStatsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Đăng xuất',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade500,
      letterSpacing: 0.5,
    ),
  );

  Widget _menuCard({required List<Widget> children}) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(children: children),
  );

  Widget _divider() => Divider(
    height: 1,
    indent: 56,
    endIndent: 16,
    color: Colors.grey.shade100,
  );

  Widget _menuItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
