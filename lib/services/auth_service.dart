import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_response_model.dart';
import '../utils/token_storage.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.7:3000/api/auth';

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final auth = AuthResponse.fromJson(data);
      if (auth.token != null) {
        await TokenStorage.save(auth.token!);
      }
      return auth;
    } else {
      throw Exception(data['message']);
    }
  }

  static Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Đăng ký thất bại');
    }
  }

  static Future<void> logout() async {
    await TokenStorage.clear();
  }

  // ✅ Gửi mã xác nhận về email
  static Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gửi mã thất bại');
    }
  }

  // ✅ Đặt lại mật khẩu bằng mã xác nhận
  static Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'new_password': newPassword,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Đặt lại mật khẩu thất bại');
    }
  }
}
