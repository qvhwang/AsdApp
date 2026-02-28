import '../models/mchat_question_model.dart';
import '../services/admin_mchat_service.dart';

class AdminMchatController {
  Future<List<MchatQuestion>> getQuestions() async {
    try {
      return await AdminMchatService.getQuestions();
    } catch (e) {
      throw Exception('Không tải được câu hỏi: $e');
    }
  }

  Future<void> saveQuestion(MchatQuestion question) async {
    if (question.id == null) {
      await AdminMchatService.createQuestion(question);
    } else {
      await AdminMchatService.updateQuestion(question);
    }
  }
}
