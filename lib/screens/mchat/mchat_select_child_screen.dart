import 'package:flutter/material.dart';

import '../../models/child_model.dart';
import '../../services/child_service.dart';
import 'mchat_screen.dart';

class MChatSelectChildScreen extends StatefulWidget {
  final int userId;

  const MChatSelectChildScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  State<MChatSelectChildScreen> createState() => _MChatSelectChildScreenState();
}

class _MChatSelectChildScreenState extends State<MChatSelectChildScreen> {
  List<ChildModel> children = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    try {
      final result = await ChildService.getChildrenByUser(widget.userId);
      setState(() => children = result);
    } catch (_) {}
    setState(() => isLoading = false);
  }

  void _startMChat(ChildModel child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MChatScreen(
          userId: widget.userId,
          childId: child.id,
          childName: child.fullName,
        ),
      ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final datePart = raw.split('T').first;
    final parts = datePart.split('-');
    if (parts.length != 3) return raw;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn trẻ để sàng lọc M-CHAT'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF2F7F6),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : children.isEmpty
          ? const Center(child: Text('Chưa có hồ sơ trẻ'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: children.length,
              itemBuilder: (_, i) {
                final c = children[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.teal.withOpacity(0.15),
                          child: const Icon(
                            Icons.child_care,
                            color: Colors.teal,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.fullName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ngày sinh: ${_formatDate(c.birthDate)}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _startMChat(c),
                          child: const Text('Chọn'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
