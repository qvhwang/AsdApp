import 'package:flutter/material.dart';

import '../../controllers/admin_mchat_controller.dart';
import '../../models/mchat_question_model.dart';
import '../../widgets/app_toast.dart';
import 'admin_mchat_question_detail_screen.dart';

class AdminMchatQuestionScreen extends StatefulWidget {
  const AdminMchatQuestionScreen({super.key});

  @override
  State<AdminMchatQuestionScreen> createState() =>
      _AdminMchatQuestionScreenState();
}

class _AdminMchatQuestionScreenState extends State<AdminMchatQuestionScreen> {
  final AdminMchatController _controller = AdminMchatController();
  late Future<List<MchatQuestion>> _futureQuestions;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureQuestions = _controller.getQuestions();
  }

  void _refresh() => setState(() => _loadData());

  Future<void> _openDetail({
    MchatQuestion? question,
    int questionIndex = 0,
  }) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminMchatQuestionDetailScreen(
          question: question,
          questionIndex: questionIndex,
        ),
      ),
    );

    _refresh();

    if (!mounted || result == null) return;
    AppToast.show(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý câu hỏi M-CHAT')),
      body: FutureBuilder<List<MchatQuestion>>(
        future: _futureQuestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final questions = snapshot.data ?? [];

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: 20,
            itemBuilder: (context, index) {
              if (index < questions.length) {
                return _questionItem(
                  index + 1,
                  questions[index],
                  () => _openDetail(
                    question: questions[index],
                    questionIndex: index + 1,
                  ),
                );
              } else {
                return _addItem(
                  index + 1,
                  () => _openDetail(questionIndex: index + 1),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _questionItem(int index, MchatQuestion question, VoidCallback onTap) {
    final isActive = question.isActive == 1;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade50 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? Colors.blue : Colors.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Câu $index',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                question.questionText,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isActive ? 'Đang bật' : 'Đang tắt',
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addItem(int index, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline, size: 40),
              const SizedBox(height: 8),
              Text('Thêm câu $index'),
            ],
          ),
        ),
      ),
    );
  }
}
