import '../models/stats_model.dart';
import '../services/stats_service.dart';

class StatsController {
  Future<ScreeningStats?> getScreeningStats({String? from, String? to}) async {
    try {
      return await StatsService.getScreeningStats(from: from, to: to);
    } catch (e) {
      return null;
    }
  }

  Future<List<UserStat>> getUserStats({String sort = 'count'}) async {
    try {
      return await StatsService.getUserStats(sort: sort);
    } catch (e) {
      return [];
    }
  }
}
