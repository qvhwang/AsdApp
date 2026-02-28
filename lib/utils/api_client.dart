import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'token_storage.dart';

class ApiClient {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.get();
    debugPrint('🔑 ApiClient TOKEN: $token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(Uri url) async {
    final h = await _headers();
    debugPrint('📡 GET $url | Auth: ${h['Authorization']}');
    return http.get(url, headers: h);
  }

  static Future<http.Response> post(Uri url, {Object? body}) async {
    final h = await _headers();
    debugPrint('📡 POST $url | Auth: ${h['Authorization']}');
    return http.post(url, headers: h, body: body);
  }

  static Future<http.Response> put(Uri url, {Object? body}) async {
    final h = await _headers();
    debugPrint('📡 PUT $url | Auth: ${h['Authorization']}');
    return http.put(url, headers: h, body: body);
  }

  static Future<http.Response> patch(Uri url, {Object? body}) async {
    final h = await _headers();
    debugPrint('📡 PATCH $url | Auth: ${h['Authorization']}');
    return http.patch(url, headers: h, body: body);
  }

  static Future<http.Response> delete(Uri url) async {
    final h = await _headers();
    debugPrint('📡 DELETE $url | Auth: ${h['Authorization']}');
    return http.delete(url, headers: h);
  }
}
