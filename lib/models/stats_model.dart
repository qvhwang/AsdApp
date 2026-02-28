class ScreeningSummary {
  final int total;
  final int high;
  final int medium;
  final int low;

  ScreeningSummary({
    required this.total,
    required this.high,
    required this.medium,
    required this.low,
  });

  factory ScreeningSummary.fromJson(Map<String, dynamic> json) {
    return ScreeningSummary(
      total: int.tryParse(json['total'].toString()) ?? 0,
      high: int.tryParse(json['high'].toString()) ?? 0,
      medium: int.tryParse(json['medium'].toString()) ?? 0,
      low: int.tryParse(json['low'].toString()) ?? 0,
    );
  }
}

class ScreeningDetail {
  final int id;
  final String userName;
  final String childName;
  final String riskLevel;
  final int totalScore;
  final String createdAt;

  ScreeningDetail({
    required this.id,
    required this.userName,
    required this.childName,
    required this.riskLevel,
    required this.totalScore,
    required this.createdAt,
  });

  factory ScreeningDetail.fromJson(Map<String, dynamic> json) {
    return ScreeningDetail(
      id: json['id'],
      userName: json['user_name'] ?? '',
      childName: json['child_name'] ?? '',
      riskLevel: json['risk_level'] ?? '',
      totalScore: json['total_score'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class ScreeningStats {
  final ScreeningSummary summary;
  final List<ScreeningDetail> details;

  ScreeningStats({required this.summary, required this.details});

  factory ScreeningStats.fromJson(Map<String, dynamic> json) {
    return ScreeningStats(
      summary: ScreeningSummary.fromJson(json['summary']),
      details: (json['details'] as List)
          .map((e) => ScreeningDetail.fromJson(e))
          .toList(),
    );
  }
}

class UserStat {
  final int id;
  final String fullName;
  final String email;
  final int totalChildren;
  final int totalScreenings;
  final String? lastScreening;

  UserStat({
    required this.id,
    required this.fullName,
    required this.email,
    required this.totalChildren,
    required this.totalScreenings,
    this.lastScreening,
  });

  factory UserStat.fromJson(Map<String, dynamic> json) {
    return UserStat(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      totalChildren: int.tryParse(json['total_children'].toString()) ?? 0,
      totalScreenings:
      int.tryParse(json['total_screenings'].toString()) ?? 0,
      lastScreening: json['last_screening'],
    );
  }
}