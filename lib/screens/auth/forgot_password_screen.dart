import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/app_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 1;
  bool _loading = false;

  final emailCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  bool obscureNew = true;
  bool obscureConfirm = true;

  Future<void> _sendCode() async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) {
      AppToast.show(context, 'Vui lòng nhập email', success: false);
      return;
    }
    if (!email.endsWith('@gmail.com')) {
      AppToast.show(context, 'Email phải có dạng @gmail.com', success: false);
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.forgotPassword(email);
      if (!mounted) return;
      AppToast.show(context, 'Mã xác nhận đã được gửi đến $email');
      setState(() => _step = 2);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        success: false,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final code = codeCtrl.text.trim();
    final newPass = newPassCtrl.text;
    final confirm = confirmPassCtrl.text;

    if (code.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      AppToast.show(context, 'Vui lòng điền đầy đủ thông tin', success: false);
      return;
    }
    if (code.length != 6) {
      AppToast.show(context, 'Mã xác nhận phải là 6 chữ số', success: false);
      return;
    }
    if (newPass.length < 6) {
      AppToast.show(context, 'Mật khẩu tối thiểu 6 ký tự', success: false);
      return;
    }
    if (newPass != confirm) {
      AppToast.show(context, 'Mật khẩu xác nhận không khớp', success: false);
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.resetPassword(
        email: emailCtrl.text.trim(),
        code: code,
        newPassword: newPass,
      );
      if (!mounted) return;
      AppToast.show(context, 'Đặt lại mật khẩu thành công! Hãy đăng nhập.');
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        success: false,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.teal,
        title: const Text(
          'Quên mật khẩu',
          style: TextStyle(color: Colors.teal),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: _step == 1 ? _buildStep1() : _buildStep2(),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.teal.withOpacity(0.12),
                child: const Icon(
                  Icons.lock_reset,
                  size: 44,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Đặt lại mật khẩu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Nhập email đã đăng ký, chúng tôi\nsẽ gửi mã xác nhận đến email của bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        _label('Email'),
        const SizedBox(height: 8),
        TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDeco(
            hint: 'example@gmail.com',
            icon: Icons.email_outlined,
          ),
        ),

        const SizedBox(height: 28),

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
            onPressed: _loading ? null : _sendCode,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Gửi mã xác nhận', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.teal.withOpacity(0.12),
                child: const Icon(
                  Icons.mark_email_read,
                  size: 44,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Nhập mã xác nhận',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Mã 6 số đã được gửi đến\n${emailCtrl.text.trim()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        _label('Mã xác nhận'),
        const SizedBox(height: 8),
        TextField(
          controller: codeCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
          decoration: _inputDeco(
            hint: '------',
            icon: Icons.pin,
          ).copyWith(counterText: ''),
        ),

        const SizedBox(height: 16),

        _label('Mật khẩu mới'),
        const SizedBox(height: 8),
        TextField(
          controller: newPassCtrl,
          obscureText: obscureNew,
          decoration: _inputDeco(
            hint: 'Tối thiểu 6 ký tự',
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => obscureNew = !obscureNew),
            ),
          ),
        ),

        const SizedBox(height: 16),

        _label('Xác nhận mật khẩu mới'),
        const SizedBox(height: 8),
        TextField(
          controller: confirmPassCtrl,
          obscureText: obscureConfirm,
          decoration: _inputDeco(
            hint: 'Nhập lại mật khẩu',
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                obscureConfirm ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
            ),
          ),
        ),

        const SizedBox(height: 28),

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
            onPressed: _loading ? null : _resetPassword,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Đặt lại mật khẩu',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),

        const SizedBox(height: 12),

        Center(
          child: TextButton(
            onPressed: _loading ? null : () => setState(() => _step = 1),
            child: const Text(
              'Gửi lại mã',
              style: TextStyle(color: Colors.teal),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: Colors.black87,
    ),
  );

  InputDecoration _inputDeco({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.teal),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
    );
  }
}
