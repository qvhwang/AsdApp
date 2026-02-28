import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/child_model.dart';
import '../utils/token_storage.dart';

class ChildService {
  static const String baseUrl = 'http://192.168.1.7:3000/api/children';

  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.get();
    debugPrint('🔑 TOKEN: $token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<ChildModel>> getChildrenByUser(int userId) async {
    final url = Uri.parse('$baseUrl/user/$userId');
    debugPrint('📡 GET $url');

    final headers = await _headers();
    final res = await http.get(url, headers: headers);

    debugPrint('📥 STATUS: ${res.statusCode}');
    debugPrint('📥 BODY: ${res.body}');

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ChildModel.fromJson(e)).toList();
    } else {
      throw Exception('Không tải được danh sách trẻ');
    }
  }

  static Future<void> createChild({
    required int userId,
    required String fullName,
    required String gender,
    required String birthDate,
    required String guardianName,
  }) async {
    final url = Uri.parse(baseUrl);
    final body = jsonEncode({
      'user_id': userId,
      'full_name': fullName,
      'gender': gender,
      'birth_date': birthDate,
      'guardian_name': guardianName,
    });

    debugPrint('📡 POST $url');
    debugPrint('📤 BODY: $body');

    final headers = await _headers();
    final res = await http.post(url, headers: headers, body: body);

    debugPrint('📥 STATUS: ${res.statusCode}');
    debugPrint('📥 BODY: ${res.body}');

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Không thể thêm hồ sơ trẻ: ${res.body}');
    }
  }

  static Future<void> updateChild({
    required int id,
    required String fullName,
    required String gender,
    required String birthDate,
    required String guardianName,
  }) async {
    final url = Uri.parse('$baseUrl/$id');
    final body = jsonEncode({
      'full_name': fullName,
      'gender': gender,
      'birth_date': birthDate,
      'guardian_name': guardianName,
    });

    debugPrint('📡 PUT $url');
    debugPrint('📤 BODY: $body');

    final headers = await _headers();
    final res = await http.put(url, headers: headers, body: body);

    debugPrint('📥 STATUS: ${res.statusCode}');
    debugPrint('📥 BODY: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Cập nhật hồ sơ thất bại: ${res.body}');
    }
  }

  static Future<void> deleteChild(int id) async {
    final url = Uri.parse('$baseUrl/$id');
    debugPrint('📡 DELETE $url');

    final headers = await _headers();
    final res = await http.delete(url, headers: headers);

    debugPrint('📥 STATUS: ${res.statusCode}');
    debugPrint('📥 BODY: ${res.body}');

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Xóa thất bại: ${res.body}');
    }
  }
}
