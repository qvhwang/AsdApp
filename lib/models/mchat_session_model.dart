class MChatSession {
  final int id;
  final int totalScore;
  final String riskLevel;
  final String createdAt;

  MChatSession({
    required this.id,
    required this.totalScore,
    required this.riskLevel,
    required this.createdAt,
  });

  factory MChatSession.fromJson(Map<String, dynamic> json) {
    return MChatSession(
      id: json['id'],
      totalScore: json['total_score'],
      riskLevel: json['risk_level'],
      createdAt: json['created_at'],
    );
  }
}

class MChatSessionDetail {
  final String questionText;
  final String answer;
  final int isRisk;

  MChatSessionDetail({
    required this.questionText,
    required this.answer,
    required this.isRisk,
  });

  factory MChatSessionDetail.fromJson(Map<String, dynamic> json) {
    return MChatSessionDetail(
      questionText: json['question_text'] ?? '',
      answer: json['answer'],
      isRisk: json['is_risk'],
    );
  }
}

class MChatResult {
  final int totalScore;
  final String riskLevel;

  MChatResult({required this.totalScore, required this.riskLevel});

  factory MChatResult.fromJson(Map<String, dynamic> json) {
    return MChatResult(
      totalScore: json['total_score'],
      riskLevel: json['risk_level'],
    );
  }
}
