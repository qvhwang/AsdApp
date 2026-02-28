import 'dart:convert';

import '../models/chat_message_model.dart';
import '../utils/api_client.dart';

class AIService {
  static const String baseUrl = 'http://192.168.1.7:3000/api/ai';

  // ===== LẤY LỊCH SỬ CHAT =====
  static Future<List<ChatMessage>> getHistory(int childId) async {
    final res = await ApiClient.get(Uri.parse('$baseUrl/history/$childId'));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ChatMessage.fromJson(e)).toList();
    } else {
      throw Exception('Không tải được lịch sử chat');
    }
  }

  // ===== HỎI AI =====
  static Future<String> askAI({
    required int userId,
    required int childId,
    required String question,
  }) async {
    final res = await ApiClient.post(
      Uri.parse('$baseUrl/ask'),
      body: jsonEncode({
        'user_id': userId,
        'child_id': childId,
        'question': question,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['response'];
    } else {
      final data = jsonDecode(res.body);
      throw Exception(data['message'] ?? 'AI không phản hồi');
    }
  }
}
