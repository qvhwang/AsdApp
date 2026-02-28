import 'package:flutter/material.dart';

import '../../controllers/child_controller.dart';
import '../../models/child_model.dart';
import '../../models/user_model.dart';
import '../../utils/utils.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../mchat/mchat_history_screen.dart';
import '../mchat/mchat_screen.dart';
import 'edit_child_screen.dart';

class ChildDetailModal extends StatelessWidget {
  final ChildModel child;
  final UserModel user;

  ChildDetailModal({Key? key, required this.child, required this.user})
    : super(key: key);

  final ChildController controller = ChildController();

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '';
    final datePart = value.split('T').first;
    final parts = datePart.split('-');
    if (parts.length != 3) return value;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  Future<void> _deleteChild(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa hồ sơ'),
        content: const Text('Bạn có chắc muốn xóa hồ sơ trẻ này không?'),
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
    final success = await controller.deleteChild(child.id);
    if (success) {
      showToast(context, '🗑️ Xóa hồ sơ thành công');
      Navigator.pop(context, true);
    } else {
      showToast(context, 'Xóa hồ sơ thất bại', success: false);
    }
  }

  void _startMChat(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MChatScreen(
          userId: user.id,
          childId: child.id,
          childName: child.fullName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F7F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.child_care, color: Colors.teal),
              const Text(
                'Chi tiết hồ sơ trẻ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.child_care, size: 56, color: Colors.teal),
            ),
          ),

          const SizedBox(height: 24),

          _infoRow('Họ tên', child.fullName),
          _infoRow('Ngày sinh', _formatDate(child.birthDate)),
          _infoRow('Giới tính', child.gender),
          _infoRow('Người giám hộ', child.guardianName),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startMChat(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Thực hiện sàng lọc M-CHAT-R/F',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MChatHistoryScreen(
                    childId: child.id,
                    childName: child.fullName,
                  ),
                ),
              ),
              child: const Text('Lịch sử M-CHAT'),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                final updated = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => EditChildModal(child: child),
                );
                if (updated == true) Navigator.pop(context, true);
              },
              child: const Text('Chỉnh sửa hồ sơ'),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AIChatScreen(child: child, user: user),
                  ),
                );
              },
              icon: const Icon(Icons.smart_toy),
              label: const Text('Tư vấn AI'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _deleteChild(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Xóa hồ sơ'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value?.toString() ?? '',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
