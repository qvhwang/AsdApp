import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/child_model.dart';
import '../../models/user_model.dart';
import '../../services/child_service.dart';
import '../../widgets/app_toast.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../child/child_list_screen.dart';
import '../guide/guide_screen.dart';
import '../mchat/mchat_select_child_screen.dart';
import '../profile/user_info_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  Future<void> _openAIConsultation() async {
    try {
      final children = await ChildService.getChildrenByUser(user.id);
      if (children.isEmpty) {
        AppToast.show(context, 'Vui lòng thêm hồ sơ trẻ trước', success: false);
        return;
      }
      final selectedChild = await _selectChild(children);
      if (selectedChild != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AIChatScreen(child: selectedChild, user: user),
          ),
        );
      }
    } catch (e) {
      AppToast.show(context, '$e', success: false);
    }
  }

  Future<ChildModel?> _selectChild(List<ChildModel> children) {
    return showModalBottomSheet<ChildModel>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chọn hồ sơ trẻ để tư vấn',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children.map(
              (child) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.withOpacity(0.15),
                  child: const Icon(Icons.child_care, color: Colors.teal),
                ),
                title: Text(child.fullName),
                onTap: () => Navigator.pop(context, child),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCamera() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Phân tích ảnh',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Chọn cách lấy ảnh',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.withOpacity(0.12),
                child: const Icon(Icons.camera_alt, color: Colors.teal),
              ),
              title: const Text('Chụp ảnh'),
              subtitle: const Text('Mở camera để chụp'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.12),
                child: const Icon(Icons.photo_library, color: Colors.blue),
              ),
              title: const Text('Chọn từ thư viện'),
              subtitle: const Text('Ảnh có sẵn trong máy'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);

    if (picked == null || !mounted) return;

    _showConfirmSend();
  }

  void _showConfirmSend() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Icon(Icons.image_outlined, size: 48, color: Colors.teal),
            const SizedBox(height: 12),
            const Text(
              'Ảnh đã được chọn',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bạn có muốn gửi ảnh này để phân tích không?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  AppToast.show(
                    context,
                    'Chức năng đang trong quá trình phát triển',
                    success: false,
                  );
                },
                child: const Text(
                  'Xác nhận gửi ảnh này',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon() {
    AppToast.show(
      context,
      'Chức năng đang trong quá trình phát triển',
      success: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6F5),
      body: Column(
        children: [
          _buildHeader(greeting),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bạn muốn làm gì hôm nay?',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  _featureItem(
                    icon: Icons.child_care,
                    label: 'Hồ sơ trẻ',
                    subtitle: 'Quản lý thông tin con',
                    color: const Color(0xFF26A69A),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) =>
                          ChildListModal(userId: user.id, userModel: user),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _featureItem(
                    icon: Icons.fact_check_outlined,
                    label: 'Bắt đầu sàng lọc',
                    subtitle: 'Kiểm tra M-CHAT-R/F',
                    color: const Color(0xFF42A5F5),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MChatSelectChildScreen(userId: user.id),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _featureItem(
                    icon: Icons.smart_toy_outlined,
                    label: 'Chatbot hỗ trợ',
                    subtitle: 'Tư vấn AI về phát triển trẻ',
                    color: const Color(0xFF7E57C2),
                    onTap: _openAIConsultation,
                  ),
                  const SizedBox(height: 12),
                  _featureItem(
                    icon: Icons.menu_book_outlined,
                    label: 'Kiến thức về tự kỷ',
                    subtitle: 'Hướng dẫn & lưu ý sử dụng',
                    color: const Color(0xFFFF8A65),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GuideScreen()),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _historyButton(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader(String greeting) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00897B), Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Xin chào, ${user.fullName.split(' ').last}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final updatedUser = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserInfoScreen(user: user),
                    ),
                  );
                  if (updatedUser != null) {
                    setState(() => user = updatedUser);
                  }
                },
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName
                              .trim()
                              .split(' ')
                              .last
                              .substring(0, 1)
                              .toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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

  Widget _featureItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: _showComingSoon,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.history, color: Colors.teal, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xem kết quả trước đó',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Lịch sử sàng lọc đã thực hiện',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // HOME
              Expanded(
                child: InkWell(
                  onTap: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_rounded, color: Colors.teal, size: 26),
                      const SizedBox(height: 2),
                      Text(
                        'Trang chủ',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: _openCamera,
                child: Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00897B), Color(0xFF26C6DA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),

              // PROFILE
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final updatedUser = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserInfoScreen(user: user),
                      ),
                    );
                    if (updatedUser != null) {
                      setState(() => user = updatedUser);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        color: Colors.grey.shade500,
                        size: 26,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tài khoản',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng ☀️';
    if (hour < 18) return 'Chào buổi chiều 🌤️';
    return 'Chào buổi tối 🌙';
  }
}
