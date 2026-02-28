import '../models/mchat_question_model.dart';
import '../models/mchat_session_model.dart';
import '../services/mchat_service.dart';

class MChatController {
  Future<List<MchatQuestion>> getQuestions() async {
    try {
      return await MChatService.getQuestions();
    } catch (e) {
      return [];
    }
  }

  Future<bool> submitAnswer({
    required int sessionId,
    required int questionId,
    required String answer,
  }) async {
    try {
      await MChatService.submitAnswer(
        sessionId: sessionId,
        questionId: questionId,
        answer: answer,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int?> createSession({
    required int userId,
    required int childId,
  }) async {
    try {
      return await MChatService.createSession(userId: userId, childId: childId);
    } catch (e) {
      return null;
    }
  }

  Future<MChatResult?> finishSession(int sessionId) async {
    try {
      return await MChatService.finishSession(sessionId);
    } catch (e) {
      return null;
    }
  }

  Future<List<MChatSession>> getHistory(int childId) async {
    try {
      return await MChatService.getHistory(childId);
    } catch (e) {
      return [];
    }
  }

  Future<List<MChatSessionDetail>> getSessionDetail(int sessionId) async {
    try {
      return await MChatService.getSessionDetail(sessionId);
    } catch (e) {
      return [];
    }
  }
}
