import 'package:flutter/material.dart';

import '../../controllers/admin_user_controller.dart';
import '../../models/user_model.dart';
import '../../widgets/app_toast.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final AdminUserController _controller = AdminUserController();

  List<UserModel> _users = [];
  List<UserModel> _filtered = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final users = await _controller.getUsers();
      setState(() {
        _users = users;
        _filtered = users;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showSnack('Lỗi: $e', success: false);
    }
  }

  void _onSearch(String value) {
    setState(() {
      _search = value;
      _filtered = _users
          .where(
            (u) =>
                u.fullName.toLowerCase().contains(value.toLowerCase()) ||
                u.email.toLowerCase().contains(value.toLowerCase()),
          )
          .toList();
    });
  }

  void _showSnack(String msg, {bool success = true}) {
    AppToast.show(context, msg, success: success);
  }

  Future<void> _openForm({UserModel? user}) async {
    final nameCtrl = TextEditingController(text: user?.fullName ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final passCtrl = TextEditingController();
    String role = user?.role ?? 'USER';
    int status = user?.status ?? 1;
    bool loading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(user == null ? 'Thêm tài khoản' : 'Sửa tài khoản'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Họ tên',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (user == null) ...[
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu (tối thiểu 6 ký tự)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'USER', child: Text('USER')),
                    DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                  ],
                  onChanged: (v) => setLocal(() => role = v!),
                ),
                if (user != null) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: status,
                    decoration: const InputDecoration(
                      labelText: 'Trạng thái',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Hoạt động')),
                      DropdownMenuItem(value: 0, child: Text('Bị khóa')),
                    ],
                    onChanged: (v) => setLocal(() => status = v!),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty ||
                          emailCtrl.text.trim().isEmpty) {
                        _showSnack(
                          'Vui lòng nhập đầy đủ thông tin',
                          success: false,
                        );
                        return;
                      }
                      if (!emailCtrl.text.trim().endsWith('@gmail.com') ||
                          !RegExp(
                            r'^[\w.]+@gmail\.com$',
                          ).hasMatch(emailCtrl.text.trim())) {
                        _showSnack(
                          'Email phải có dạng @gmail.com',
                          success: false,
                        );
                        return;
                      }
                      if (user == null && passCtrl.text.isEmpty) {
                        _showSnack('Vui lòng nhập mật khẩu', success: false);
                        return;
                      }
                      if (user == null && passCtrl.text.length < 6) {
                        _showSnack(
                          'Mật khẩu tối thiểu 6 ký tự',
                          success: false,
                        );
                        return;
                      }

                      setLocal(() => loading = true);
                      try {
                        if (user == null) {
                          await _controller.createUser(
                            fullName: nameCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            password: passCtrl.text,
                            role: role,
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                          _showSnack(
                            'Đã thêm tài khoản ${emailCtrl.text.trim()} thành công',
                          );
                        } else {
                          await _controller.updateUser(
                            id: user.id,
                            fullName: nameCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            role: role,
                            status: status,
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                          final oldEmail = user!.email;
                          final newEmail = emailCtrl.text.trim();
                          final msg = oldEmail == newEmail
                              ? 'Đã cập nhật tài khoản $newEmail'
                              : 'Đã đổi email $oldEmail → $newEmail';
                          _showSnack(msg);
                        }
                        _load();
                      } catch (e) {
                        _showSnack('Lỗi: $e', success: false);
                      }
                      setLocal(() => loading = false);
                    },
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(user == null ? 'Thêm' : 'Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Xóa tài khoản "${user.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _controller.deleteUser(user.id);
      _showSnack('Đã xóa tài khoản ${user.email}');
      _load();
    } catch (e) {
      _showSnack('Lỗi: $e', success: false);
    }
  }

  Future<void> _toggleStatus(UserModel user) async {
    try {
      await _controller.toggleStatus(user.id, user.status);
      _showSnack(
        user.status == 1
            ? 'Đã khóa tài khoản ${user.email}'
            : 'Đã mở khóa tài khoản ${user.email}',
      );
      _load();
    } catch (e) {
      _showSnack('Lỗi: $e', success: false);
    }
  }

  Future<void> _changeRole(UserModel user) async {
    try {
      await _controller.changeRole(user.id, user.role);
      final newRole = user.role == 'ADMIN' ? 'USER' : 'ADMIN';
      _showSnack('Đã đổi ${user.email} thành $newRole');
      _load();
    } catch (e) {
      _showSnack('Lỗi: $e', success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F6),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Quản lý tài khoản'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _openForm(),
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc email...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _statChip('Tổng: ${_users.length}', Colors.teal),
                const SizedBox(width: 8),
                _statChip(
                  'Admin: ${_users.where((u) => u.role == 'ADMIN').length}',
                  Colors.deepPurple,
                ),
                const SizedBox(width: 8),
                _statChip(
                  'Khóa: ${_users.where((u) => u.status == 0).length}',
                  Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? const Center(child: Text('Không có tài khoản nào'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _userCard(_filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _userCard(UserModel user) {
    final isActive = user.status == 1;
    final isAdmin = user.role == 'ADMIN';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isAdmin
              ? Colors.deepPurple.withOpacity(0.15)
              : Colors.teal.withOpacity(0.15),
          child: Text(
            user.fullName.isNotEmpty
                ? user.fullName.substring(0, 1).toUpperCase()
                : '?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isAdmin ? Colors.deepPurple : Colors.teal,
            ),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                user.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isAdmin ? Colors.deepPurple : Colors.teal,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.role,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              user.email,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.12)
                    : Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isActive ? '● Hoạt động' : '● Bị khóa',
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (v) {
            if (v == 'edit') _openForm(user: user);
            if (v == 'toggle') _toggleStatus(user);
            if (v == 'role') _changeRole(user);
            if (v == 'delete') _deleteUser(user);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    isActive ? Icons.lock : Icons.lock_open,
                    color: isActive ? Colors.orange : Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(isActive ? 'Khóa tài khoản' : 'Mở khóa'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'role',
              child: Row(
                children: [
                  Icon(
                    isAdmin ? Icons.person : Icons.admin_panel_settings,
                    color: Colors.deepPurple,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(isAdmin ? 'Đổi thành USER' : 'Đổi thành ADMIN'),
                ],
              ),
            ),
            if (!isAdmin) ...[
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Xóa tài khoản', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
