import 'dart:convert';

import '../models/user_model.dart';
import '../utils/api_client.dart';

class AdminUserService {
  static const String baseUrl = 'http://192.168.1.7:3000/api/admin/users';

  static Future<List<UserModel>> getUsers() async {
    final res = await ApiClient.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception('Không tải được danh sách user');
    }
  }

  static Future<void> toggleStatus(int id, int currentStatus) async {
    final res = await ApiClient.put(
      Uri.parse('$baseUrl/toggle-status'),
      body: jsonEncode({'id': id, 'status': currentStatus}),
    );
    if (res.statusCode != 200) throw Exception(jsonDecode(res.body)['message']);
  }

  static Future<void> changeRole(int id, String currentRole) async {
    final res = await ApiClient.put(
      Uri.parse('$baseUrl/change-role'),
      body: jsonEncode({'id': id, 'role': currentRole}),
    );
    if (res.statusCode != 200) throw Exception(jsonDecode(res.body)['message']);
  }

  static Future<void> deleteUser(int id) async {
    final res = await ApiClient.delete(Uri.parse('$baseUrl/$id'));
    if (res.statusCode != 200) throw Exception(jsonDecode(res.body)['message']);
  }

  static Future<void> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final res = await ApiClient.post(
      Uri.parse(baseUrl),
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(jsonDecode(res.body)['message']);
    }
  }

  static Future<void> updateUser({
    required int id,
    required String fullName,
    required String email,
    required String role,
    required int status,
  }) async {
    final res = await ApiClient.put(
      Uri.parse('$baseUrl/$id'),
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'role': role,
        'status': status,
      }),
    );
    if (res.statusCode != 200) throw Exception(jsonDecode(res.body)['message']);
  }
}
