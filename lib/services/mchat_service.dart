import 'dart:convert';

import '../models/mchat_question_model.dart';
import '../models/mchat_session_model.dart';
import '../utils/api_client.dart';

class MChatService {
  static const String baseUrl = 'http://192.168.1.7:3000/api/mchat';

  static Future<List<MchatQuestion>> getQuestions() async {
    final res = await ApiClient.get(Uri.parse('$baseUrl/questions'));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => MchatQuestion.fromJson(e)).toList();
    } else {
      throw Exception('Không tải được câu hỏi M-CHAT');
    }
  }

  static Future<void> submitAnswer({
    required int sessionId,
    required int questionId,
    required String answer,
  }) async {
    final res = await ApiClient.post(
      Uri.parse('$baseUrl/answers'),
      body: jsonEncode({
        'session_id': sessionId,
        'question_id': questionId,
        'answer': answer,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gửi câu trả lời thất bại');
    }
  }

  static Future<int> createSession({
    required int userId,
    required int childId,
  }) async {
    final res = await ApiClient.post(
      Uri.parse('$baseUrl/sessions'),
      body: jsonEncode({'user_id': userId, 'child_id': childId}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['session_id'];
    } else {
      throw Exception('Không thể tạo phiên M-CHAT');
    }
  }

  static Future<MChatResult> finishSession(int sessionId) async {
    final res = await ApiClient.put(
      Uri.parse('$baseUrl/sessions/$sessionId/finish'),
    );

    if (res.statusCode == 200) {
      return MChatResult.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Không thể hoàn tất phiên M-CHAT');
    }
  }

  static Future<List<MChatSession>> getHistory(int childId) async {
    final res = await ApiClient.get(Uri.parse('$baseUrl/history/$childId'));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => MChatSession.fromJson(e)).toList();
    } else {
      throw Exception('Không tải được lịch sử M-CHAT');
    }
  }

  static Future<List<MChatSessionDetail>> getSessionDetail(
    int sessionId,
  ) async {
    final res = await ApiClient.get(Uri.parse('$baseUrl/session/$sessionId'));

    if (res.statusCode != 200)
      throw Exception('Server error ${res.statusCode}');

    final decoded = jsonDecode(res.body);
    if (decoded is! List) throw Exception('Invalid response');

    return (decoded as List)
        .map((e) => MChatSessionDetail.fromJson(e))
        .toList();
  }
}
