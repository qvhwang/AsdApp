import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_toast.dart';
import '../home/home_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool isLoading = false;
  bool obscure = true;

  Future<void> _login() async {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;

    // ✅ Validate trước khi gọi API
    if (email.isEmpty || password.isEmpty) {
      AppToast.show(context, 'Vui lòng nhập email và mật khẩu', success: false);
      return;
    }
    if (!RegExp(r'^[\w.]+@[\w]+\.[\w]+$').hasMatch(email)) {
      AppToast.show(context, 'Email không hợp lệ', success: false);
      return;
    }

    setState(() => isLoading = true);

    try {
      final auth = await AuthService.login(email: email, password: password);

      if (!mounted) return;

      final user = UserModel(
        id: auth.user!.id,
        fullName: auth.user!.fullName,
        email: auth.user!.email,
        role: auth.user!.role,
        status: auth.user!.status,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');

      // ✅ Thông báo chi tiết từng trường hợp
      String display;
      if (msg.contains('khóa') || msg.contains('locked')) {
        display = 'Tài khoản đã bị khóa. Liên hệ admin để được hỗ trợ.';
      } else if (msg.contains('không đúng') ||
          msg.contains('incorrect') ||
          msg.contains('password') ||
          msg.contains('mật khẩu')) {
        display = 'Email hoặc mật khẩu không đúng';
      } else if (msg.contains('không tồn tại') ||
          msg.contains('not found') ||
          msg.contains('tìm thấy')) {
        display = 'Email không tồn tại trong hệ thống';
      } else {
        display = msg.isNotEmpty ? msg : 'Đăng nhập thất bại, thử lại sau';
      }

      AppToast.show(context, display, success: false);
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.teal.withOpacity(0.15),
                  child: const Icon(
                    Icons.child_care,
                    size: 52,
                    color: Colors.teal,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Sàng lọc M-CHAT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Đăng nhập để tiếp tục',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _login(),
              ),

              // ✅ Link quên mật khẩu
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: const Text(
                    'Quên mật khẩu?',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ),

              const SizedBox(height: 8),

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
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text.rich(
                    TextSpan(
                      text: 'Chưa có tài khoản? ',
                      style: TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          text: 'Đăng ký ngay',
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
