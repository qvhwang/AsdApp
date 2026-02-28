import 'package:flutter/material.dart';

import '../../models/child_model.dart';
import '../../models/user_model.dart';
import '../../services/child_service.dart';
import 'add_child_screen.dart';
import 'child_detail_screen.dart';

class ChildListModal extends StatefulWidget {
  final int userId;
  final UserModel? userModel;

  const ChildListModal({Key? key, required this.userId, this.userModel})
    : super(key: key);

  @override
  State<ChildListModal> createState() => _ChildListModalState();
}

class _ChildListModalState extends State<ChildListModal> {
  List<ChildModel> children = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    setState(() => isLoading = true);
    try {
      final result = await ChildService.getChildrenByUser(widget.userId);
      setState(() {
        children = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tải được danh sách hồ sơ trẻ')),
      );
    }
  }

  void _openAddChild() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddChildModal(userId: widget.userId),
    );
    if (added == true) fetchChildren();
  }

  String formatDate(String? value) {
    if (value == null || value.isEmpty) return '';
    try {
      final date = DateTime.parse(value).toLocal();
      return '${date.day.toString().padLeft(2, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.year}';
    } catch (e) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F7F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.child_care, color: Colors.teal),
              const Text(
                'Hồ sơ trẻ',
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
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : children.isEmpty
                ? _buildEmptyContent()
                : ListView.builder(
                    itemCount: children.length,
                    itemBuilder: (_, index) => _buildChildItem(children[index]),
                  ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openAddChild,
              icon: const Icon(Icons.add),
              label: const Text('Thêm hồ sơ trẻ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Chưa có hồ sơ trẻ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildChildItem(ChildModel child) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        if (widget.userModel == null) return;

        final result = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          builder: (_) =>
              ChildDetailModal(child: child, user: widget.userModel!),
        );
        if (result == true) fetchChildren();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.child_care, size: 36, color: Colors.teal),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // ✅ FIX: xử lý nullable String?
                  Text(
                    'Ngày sinh: ${formatDate(child.birthDate)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Giới tính: ${child.gender ?? ''}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Giám hộ: ${child.guardianName ?? ''}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
