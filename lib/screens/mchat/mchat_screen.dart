import 'package:flutter/material.dart';

import '../../controllers/mchat_controller.dart';
import '../../models/mchat_question_model.dart';
import '../../widgets/app_toast.dart';
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

class _MChatScreenState extends State<MChatScreen>
    with SingleTickerProviderStateMixin {
  final MChatController _controller = MChatController();

  List<MchatQuestion> questions = [];
  int current = 0;
  bool loading = true;
  bool submitting = false;
  String? _selectedAnswer; // hiển thị highlight trước khi chuyển câu

  final Map<int, String> _answers = {};

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _loadQuestions();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final result = await _controller.getQuestions();
    setState(() {
      questions = result;
      loading = false;
    });
    _animCtrl.forward();
  }

  Future<void> _answer(String ans) async {
    if (_selectedAnswer != null) return; // tránh double tap

    setState(() => _selectedAnswer = ans);

    await Future.delayed(const Duration(milliseconds: 380));

    final q = questions[current];
    _answers[q.id!] = ans;

    final isLast = current == questions.length - 1;

    if (!isLast) {
      await _animCtrl.reverse();
      setState(() {
        current++;
        _selectedAnswer = null;
      });
      _animCtrl.forward();
      return;
    }

    // Câu cuối — tạo session + submit + finish
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
      setState(() {
        submitting = false;
        _selectedAnswer = null;
      });
      if (mounted)
        AppToast.show(context, 'Lỗi lưu kết quả: $e', success: false);
    }
  }

  // Quay lại câu trước
  void _goBack() {
    if (current == 0) return;
    setState(() {
      current--;
      _selectedAnswer = null;
      // Xóa câu trả lời câu hiện tại để cho phép chọn lại
      final prevQ = questions[current];
      _answers.remove(prevQ.id);
    });
    _animCtrl.forward(from: 0);
  }

  Future<bool> _onWillPop() async {
    if (current == 0 && _answers.isEmpty) return true;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Thoát sàng lọc?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
    // LOADING
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0F6F5),
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    // EMPTY
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

    // SUBMITTING
    if (submitting) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F6F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    color: Colors.teal,
                    strokeWidth: 3,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Đang lưu kết quả...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vui lòng chờ trong giây lát',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    final q = questions[current];
    final progress = (current + 1) / questions.length;
    final answered = _answers[q.id];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F6F5),
        body: SafeArea(
          child: Column(
            children: [
              // ===== HEADER =====
              _buildHeader(progress),

              // ===== QUESTION =====
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // Số câu + tên trẻ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Câu ${current + 1} / ${questions.length}',
                              style: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.child_care,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.childName,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // QUESTION CARD
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: SlideTransition(
                            position: _slideAnim,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon câu hỏi
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.teal.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.help_outline_rounded,
                                      color: Colors.teal,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    q.questionText,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      height: 1.6,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ANSWER BUTTONS
                      Row(
                        children: [
                          // NÚT CÓ
                          Expanded(
                            child: _answerButton(
                              label: 'Có',
                              value: 'YES',
                              selected: _selectedAnswer ?? answered,
                              activeColor: Colors.teal,
                              icon: Icons.check_circle_outline,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // NÚT KHÔNG
                          Expanded(
                            child: _answerButton(
                              label: 'Không',
                              value: 'NO',
                              selected: _selectedAnswer ?? answered,
                              activeColor: Colors.redAccent,
                              icon: Icons.cancel_outlined,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // NÚT QUAY LẠI
                      if (current > 0)
                        TextButton.icon(
                          onPressed: _selectedAnswer != null ? null : _goBack,
                          icon: const Icon(Icons.arrow_back_ios, size: 14),
                          label: const Text('Câu trước'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                          ),
                        ),

                      const SizedBox(height: 8),
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

  // ===== HEADER với progress bar =====
  Widget _buildHeader(double progress) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00897B), Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () async {
                  if (await _onWillPop()) Navigator.pop(context);
                },
              ),
              const Expanded(
                child: Text(
                  'Sàng lọc M-CHAT-R/F',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}% hoàn thành',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${current + 1}/${questions.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== ANSWER BUTTON =====
  Widget _answerButton({
    required String label,
    required String value,
    required String? selected,
    required Color activeColor,
    required IconData icon,
  }) {
    final isSelected = selected == value;
    final isOther = selected != null && selected != value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 58,
      decoration: BoxDecoration(
        color: isSelected ? activeColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? activeColor
              : isOther
              ? Colors.grey.shade200
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _selectedAnswer != null ? null : () => _answer(value),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : isOther
                    ? Colors.grey.shade300
                    : Colors.grey.shade500,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : isOther
                      ? Colors.grey.shade300
                      : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
