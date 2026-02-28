import 'dart:convert';

import '../models/user_model.dart';
import '../utils/api_client.dart';

class UserService {
  static const String baseUrl = 'http://192.168.1.7:3000/api/users';

  static Future<UserModel> getUserById(int id) async {
    final res = await ApiClient.get(Uri.parse('$baseUrl/me'));
    if (res.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Không tải được thông tin người dùng');
    }
  }

  static Future<UserModel> updateProfile({
    required int id,
    required String fullName,
  }) async {
    final res = await ApiClient.put(
      Uri.parse('$baseUrl/me'),
      body: jsonEncode({'full_name': fullName}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return UserModel.fromJson(data);
    } else {
      final data = jsonDecode(res.body);
      throw Exception(data['message'] ?? 'Cập nhật thất bại');
    }
  }

  static Future<void> changePassword({
    required int id,
    required String oldPassword,
    required String newPassword,
  }) async {
    final res = await ApiClient.put(
      Uri.parse('$baseUrl/me/change-password'),
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );

    if (res.statusCode != 200) {
      final data = jsonDecode(res.body);
      throw Exception(data['message'] ?? 'Đổi mật khẩu thất bại');
    }
  }
}
