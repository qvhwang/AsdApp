import 'package:flutter/material.dart';

import '../../controllers/admin_mchat_controller.dart';
import '../../models/mchat_question_model.dart';

class AdminMchatQuestionDetailScreen extends StatefulWidget {
  final MchatQuestion? question;
  final int questionIndex;

  const AdminMchatQuestionDetailScreen({
    super.key,
    this.question,
    this.questionIndex = 0,
  });

  @override
  State<AdminMchatQuestionDetailScreen> createState() =>
      _AdminMchatQuestionDetailScreenState();
}

class _AdminMchatQuestionDetailScreenState
    extends State<AdminMchatQuestionDetailScreen> {
  final AdminMchatController _controller = AdminMchatController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController questionController;
  String riskAnswer = 'YES';
  bool isActive = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    questionController = TextEditingController(
      text: widget.question?.questionText ?? '',
    );
    riskAnswer = widget.question?.riskAnswer ?? 'YES';
    isActive = (widget.question?.isActive ?? 1) == 1;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final question = MchatQuestion(
        id: widget.question?.id,
        questionText: questionController.text,
        riskAnswer: riskAnswer,
        isActive: isActive ? 1 : 0,
      );

      await _controller.saveQuestion(question);

      if (mounted) {
        final isEdit = widget.question != null;
        final msg = isEdit
            ? 'Đã cập nhật câu ${widget.questionIndex} thành công'
            : 'Đã thêm câu ${widget.questionIndex} thành công';
        Navigator.pop(context, msg);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.question == null ? 'Thêm câu hỏi' : 'Chỉnh sửa câu hỏi',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: questionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Nội dung câu hỏi',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: riskAnswer,
                items: const [
                  DropdownMenuItem(value: 'YES', child: Text('YES')),
                  DropdownMenuItem(value: 'NO', child: Text('NO')),
                ],
                onChanged: (v) => setState(() => riskAnswer = v!),
                decoration: const InputDecoration(
                  labelText: 'Đáp án nguy cơ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Trạng thái câu hỏi'),
                subtitle: Text(isActive ? 'Đang bật' : 'Đang tắt'),
                value: isActive,
                onChanged: (value) => setState(() => isActive = value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : _save,
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text('Lưu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
