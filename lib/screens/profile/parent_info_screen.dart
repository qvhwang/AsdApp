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

  late TextEditingController nameController;
  late TextEditingController emailController;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.fullName);
    emailController = TextEditingController(text: widget.user.email);
  }

  Future<void> _updateProfile() async {
    if (nameController.text.trim().isEmpty) {
      AppToast.show(context, 'Vui lòng nhập họ tên', success: false);
      return;
    }

    setState(() => loading = true);

    final updatedUser = await _controller.updateProfile(
      id: widget.user.id,
      fullName: nameController.text.trim(),
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
      appBar: AppBar(title: const Text('Thông tin phụ huynh')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _updateProfile,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Cập nhật'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
