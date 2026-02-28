import 'package:flutter/material.dart';

import '../../controllers/mchat_controller.dart';
import '../../models/mchat_question_model.dart';
import 'mchat_result_screen.dart';

class MChatScreen extends StatefulWidget {
  final int userId;
  final int childId;
  final String childName;

  const MChatScreen({
    super.key,
    required this.userId,
    required this.childId,
    required this.childName,
  });

  @override
  State<MChatScreen> createState() => _MChatScreenState();
}

class _MChatScreenState extends State<MChatScreen> {
  final MChatController _controller = MChatController();

  List<MchatQuestion> questions = [];
  int current = 0;
  bool loading = true;
  bool submitting = false;

  final Map<int, String> _answers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final result = await _controller.getQuestions();
    setState(() {
      questions = result;
      loading = false;
    });
  }

  Future<void> _answer(String ans) async {
    final q = questions[current];
    _answers[q.id!] = ans;

    final isLast = current == questions.length - 1;

    if (!isLast) {
      setState(() => current++);
      return;
    }

    setState(() => submitting = true);

    try {
      final sessionId = await _controller.createSession(
        userId: widget.userId,
        childId: widget.childId,
      );

      if (sessionId == null) throw Exception('Không tạo được session');

      for (final entry in _answers.entries) {
        await _controller.submitAnswer(
          sessionId: sessionId,
          questionId: entry.key,
          answer: entry.value,
        );
      }

      await _controller.finishSession(sessionId);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MChatResultScreen(sessionId: sessionId),
        ),
      );
    } catch (e) {
      setState(() => submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi lưu kết quả: $e')));
    }
  }

  Future<bool> _onWillPop() async {
    if (current == 0 && _answers.isEmpty) return true;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thoát sàng lọc?'),
        content: const Text(
          'Tiến trình sẽ không được lưu nếu bạn thoát giữa chừng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tiếp tục'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Không có câu hỏi M-CHAT',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    if (submitting) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang lưu kết quả...'),
            ],
          ),
        ),
      );
    }

    final q = questions[current];
    final progress = (current + 1) / questions.length;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('M-CHAT – ${widget.childName}'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _onWillPop()) Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // PROGRESS BAR
              Row(
                children: [
                  Text(
                    'Câu ${current + 1}/${questions.length}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(Colors.teal),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      q.questionText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, height: 1.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _answer('YES'),
                      child: const Text('Có', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _answer('NO'),
                      child: const Text(
                        'Không',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
