import 'package:flutter/material.dart';

import '../../controllers/mchat_controller.dart';
import '../../models/mchat_session_model.dart';
import 'mchat_history_detail_screen.dart';

class MChatHistoryScreen extends StatefulWidget {
  final int childId;
  final String childName;

  const MChatHistoryScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<MChatHistoryScreen> createState() => _MChatHistoryScreenState();
}

class _MChatHistoryScreenState extends State<MChatHistoryScreen> {
  final MChatController _controller = MChatController();

  List<MChatSession> history = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final result = await _controller.getHistory(widget.childId);
    setState(() {
      history = result;
      loading = false;
    });
  }

  String _formatDate(String value) {
    final d = DateTime.parse(value);
    return '${d.day.toString().padLeft(2, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lịch sử M-CHAT – ${widget.childName}')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
          ? const Center(child: Text('Chưa có lịch sử M-CHAT'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (_, i) {
                final h = history[i];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.fact_check),
                    title: Text(
                      'Nguy cơ: ${h.riskLevel}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Điểm: ${h.totalScore} • ${_formatDate(h.createdAt)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MChatHistoryDetailScreen(sessionId: h.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
