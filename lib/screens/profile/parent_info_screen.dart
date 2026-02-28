import 'package:flutter/material.dart';

import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';
import '../../widgets/app_toast.dart';

class ParentInfoScreen extends StatefulWidget {
  final UserModel user;
  const ParentInfoScreen({super.key, required this.user});

  @override
  State<ParentInfoScreen> createState() => _ParentInfoScreenState();
}

class _ParentInfoScreenState extends State<ParentInfoScreen> {
  final UserController _controller = UserController();
  late TextEditingController nameCtrl;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.user.fullName);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (nameCtrl.text.trim().isEmpty) {
      AppToast.show(context, 'Vui lòng nhập họ tên', success: false);
      return;
    }
    if (nameCtrl.text.trim() == widget.user.fullName) {
      AppToast.show(context, 'Tên chưa thay đổi', success: false);
      return;
    }

    setState(() => loading = true);
    final updatedUser = await _controller.updateProfile(
      id: widget.user.id,
      fullName: nameCtrl.text.trim(),
    );
    setState(() => loading = false);

    if (!mounted) return;
    if (updatedUser != null) {
      AppToast.show(context, 'Cập nhật thành công');
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context, updatedUser);
    } else {
      AppToast.show(context, 'Cập nhật thất bại', success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6F5),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: const Text('Thông tin phụ huynh'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.teal.withOpacity(0.12),
                    child: Text(
                      widget.user.fullName.trim().isNotEmpty
                          ? widget.user.fullName
                                .trim()
                                .split(' ')
                                .last
                                .substring(0, 1)
                                .toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.user.email,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

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
                  _label('Họ và tên'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDeco(
                      hint: 'Nhập họ và tên',
                      icon: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _label('Email'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: widget.user.email),
                    enabled: false,
                    decoration: _inputDeco(hint: '', icon: Icons.email_outlined)
                        .copyWith(
                          fillColor: Colors.grey.shade100,
                          hintText: widget.user.email,
                        ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Email không thể thay đổi',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
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
                onPressed: loading ? null : _updateProfile,
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
                        'Lưu thay đổi',
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

  InputDecoration _inputDeco({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.teal),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
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
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
