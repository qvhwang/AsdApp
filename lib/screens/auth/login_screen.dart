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

    // ✅ Kiểu 0: chưa nhập gì
    if (email.isEmpty) {
      AppToast.show(context, 'Vui lòng nhập email', success: false);
      return;
    }
    if (password.isEmpty) {
      AppToast.show(context, 'Vui lòng nhập mật khẩu', success: false);
      return;
    }

    // ✅ Kiểu 1: mật khẩu chưa đủ 6 ký tự
    if (password.length < 6) {
      AppToast.show(
        context,
        'Mật khẩu phải có ít nhất 6 ký tự',
        success: false,
      );
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

      // ✅ Kiểu 2: email không tồn tại
      // ✅ Kiểu 3: đúng email nhưng sai mật khẩu
      // ✅ Kiểu 4: tài khoản bị khóa
      String display;
      if (msg.contains('không tồn tại') || msg.contains('not found')) {
        display = 'Tài khoản không tồn tại. Vui lòng kiểm tra lại email.';
      } else if (msg.contains('Mật khẩu không đúng') ||
          msg.contains('Sai email hoặc mật khẩu') ||
          msg.contains('incorrect') ||
          msg.contains('wrong')) {
        display = 'Mật khẩu không đúng. Vui lòng thử lại.';
      } else if (msg.contains('khóa') || msg.contains('locked')) {
        display = 'Tài khoản đã bị khóa. Liên hệ admin để được hỗ trợ.';
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

              // EMAIL
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

              // MẬT KHẨU
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

              // QUÊN MẬT KHẨU
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

              // NÚT ĐĂNG NHẬP
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
