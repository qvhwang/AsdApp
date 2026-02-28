import 'package:flutter/material.dart';

import '../../controllers/mchat_controller.dart';
import '../../models/mchat_session_model.dart';

class MChatResultScreen extends StatefulWidget {
  final int sessionId;

  const MChatResultScreen({super.key, required this.sessionId});

  @override
  State<MChatResultScreen> createState() => _MChatResultScreenState();
}

class _MChatResultScreenState extends State<MChatResultScreen> {
  final MChatController _controller = MChatController();

  MChatResult? result;

  @override
  void initState() {
    super.initState();
    _fetchResult();
  }

  Future<void> _fetchResult() async {
    final data = await _controller.finishSession(widget.sessionId);
    setState(() => result = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả M-CHAT')),
      body: result == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tổng điểm: ${result!.totalScore}',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mức nguy cơ: ${result!.riskLevel}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hoàn tất'),
                  ),
                ],
              ),
            ),
    );
  }
}
