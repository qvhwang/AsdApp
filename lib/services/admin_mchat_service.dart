import 'dart:convert';

import '../models/mchat_question_model.dart';
import '../utils/api_client.dart';

class AdminMchatService {
  static const String baseUrl =
      'http://192.168.1.7:3000/api/admin/mchat/questions';

  static Future<List<MchatQuestion>> getQuestions() async {
    final res = await ApiClient.get(Uri.parse(baseUrl));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => MchatQuestion.fromJson(e)).toList();
    } else {
      throw Exception('Không tải được câu hỏi');
    }
  }

  static Future<void> createQuestion(MchatQuestion question) async {
    final res = await ApiClient.post(
      Uri.parse(baseUrl),
      body: jsonEncode(question.toJson()),
    );

    if (res.statusCode != 201) {
      throw Exception(res.body);
    }
  }

  static Future<void> updateQuestion(MchatQuestion question) async {
    final res = await ApiClient.put(
      Uri.parse('$baseUrl/${question.id}'),
      body: jsonEncode(question.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }
  }
}
