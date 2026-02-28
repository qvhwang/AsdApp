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
  bool obscureOld = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    oldCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

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
    if (oldCtrl.text == newCtrl.text) {
      AppToast.show(
        context,
        'Mật khẩu mới phải khác mật khẩu hiện tại',
        success: false,
      );
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
      backgroundColor: const Color(0xFFF0F6F5),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: const Text('Đổi mật khẩu'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.teal.withOpacity(0.1),
                child: const Icon(
                  Icons.lock_outline,
                  size: 44,
                  color: Colors.teal,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bảo mật tài khoản',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Mật khẩu phải có ít nhất 6 ký tự',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Mật khẩu hiện tại'),
                  const SizedBox(height: 8),
                  _passField(
                    ctrl: oldCtrl,
                    hint: 'Nhập mật khẩu hiện tại',
                    obscure: obscureOld,
                    onToggle: () => setState(() => obscureOld = !obscureOld),
                  ),

                  const SizedBox(height: 16),
                  _label('Mật khẩu mới'),
                  const SizedBox(height: 8),
                  _passField(
                    ctrl: newCtrl,
                    hint: 'Tối thiểu 6 ký tự',
                    obscure: obscureNew,
                    onToggle: () => setState(() => obscureNew = !obscureNew),
                  ),

                  const SizedBox(height: 16),
                  _label('Xác nhận mật khẩu mới'),
                  const SizedBox(height: 8),
                  _passField(
                    ctrl: confirmCtrl,
                    hint: 'Nhập lại mật khẩu mới',
                    obscure: obscureConfirm,
                    onToggle: () =>
                        setState(() => obscureConfirm = !obscureConfirm),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: loading ? null : _changePassword,
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Cập nhật mật khẩu',
                        style: TextStyle(fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 13,
      color: Colors.black87,
    ),
  );

  Widget _passField({
    required TextEditingController ctrl,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.teal),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5),
        ),
      ),
    );
  }
}
