import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message_model.dart';

class AIService {
  static const String baseUrl = 'http://192.168.1.7:3000/api/ai';

  static Future<List<ChatMessage>> getHistory(int childId) async {
    final res = await http.get(Uri.parse('$baseUrl/history/$childId'));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ChatMessage.fromJson(e)).toList();
    } else {
      throw Exception('Không tải được lịch sử chat');
    }
  }

  static Future<String> askAI({
    required int userId,
    required int childId,
    required String question,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/ask'),
      headers: {'Content-Type': 'application/json'},
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
      throw Exception('AI không phản hồi');
    }
  }
}
