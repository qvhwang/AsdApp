import 'package:flutter/material.dart';

import '../../controllers/mchat_controller.dart';
import '../../models/mchat_session_model.dart';

class MChatHistoryDetailScreen extends StatefulWidget {
  final int sessionId;

  const MChatHistoryDetailScreen({super.key, required this.sessionId});

  @override
  State<MChatHistoryDetailScreen> createState() =>
      _MChatHistoryDetailScreenState();
}

class _MChatHistoryDetailScreenState extends State<MChatHistoryDetailScreen> {
  final MChatController _controller = MChatController();

  List<MChatSessionDetail> data = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final result = await _controller.getSessionDetail(widget.sessionId);
      setState(() {
        data = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Không thể tải chi tiết M-CHAT';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết M-CHAT'),
        backgroundColor: Colors.teal,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            )
          : data.isEmpty
          ? const Center(child: Text('Không có dữ liệu'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (_, i) {
                final q = data[i];
                final isRisk = q.isRisk == 1;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isRisk ? Colors.red : Colors.green,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Câu ${i + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        q.questionText,
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Chip(
                            label: Text(q.answer == 'YES' ? 'Có' : 'Không'),
                            backgroundColor: Colors.teal.withOpacity(0.15),
                          ),
                          const SizedBox(width: 12),
                          if (isRisk)
                            const Chip(
                              label: Text('Nguy cơ'),
                              backgroundColor: Colors.redAccent,
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
