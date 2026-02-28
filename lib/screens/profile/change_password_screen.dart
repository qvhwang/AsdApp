import 'package:flutter/material.dart';

import '../../controllers/user_controller.dart';
import '../../widgets/app_toast.dart';

class ChangePasswordScreen extends StatefulWidget {
  final int userId;

  const ChangePasswordScreen({super.key, required this.userId});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final UserController _controller = UserController();

  final oldCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool loading = false;

  Future<void> _changePassword() async {
    if (oldCtrl.text.isEmpty ||
        newCtrl.text.isEmpty ||
        confirmCtrl.text.isEmpty) {
      AppToast.show(context, 'Vui lòng nhập đầy đủ thông tin', success: false);
      return;
    }
    if (newCtrl.text.length < 6) {
      AppToast.show(context, 'Mật khẩu mới tối thiểu 6 ký tự', success: false);
      return;
    }
    if (newCtrl.text != confirmCtrl.text) {
      AppToast.show(context, 'Xác nhận mật khẩu không khớp', success: false);
      return;
    }

    setState(() => loading = true);

    final error = await _controller.changePassword(
      id: widget.userId,
      oldPassword: oldCtrl.text,
      newPassword: newCtrl.text,
    );

    setState(() => loading = false);
    if (!mounted) return;

    if (error == null) {
      AppToast.show(context, 'Đổi mật khẩu thành công');
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } else {
      AppToast.show(context, error, success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đổi mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _changePassword,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Cập nhật mật khẩu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
