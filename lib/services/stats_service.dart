import 'dart:convert';

import '../models/stats_model.dart';
import '../utils/api_client.dart';

class StatsService {
  static const String baseUrl = 'http://192.168.1.7:3000/api/admin/stats';

  static Future<ScreeningStats> getScreeningStats({
    String? from,
    String? to,
  }) async {
    final params = <String, String>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;

    final uri = Uri.parse(
      '$baseUrl/screening',
    ).replace(queryParameters: params.isEmpty ? null : params);

    final res = await ApiClient.get(uri);

    if (res.statusCode == 200) {
      return ScreeningStats.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Không tải được dữ liệu thống kê');
    }
  }

  static Future<List<UserStat>> getUserStats({String sort = 'count'}) async {
    final uri = Uri.parse(
      '$baseUrl/users',
    ).replace(queryParameters: {'sort': sort});

    final res = await ApiClient.get(uri);

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => UserStat.fromJson(e)).toList();
    } else {
      throw Exception('Không tải được thống kê người dùng');
    }
  }
}
