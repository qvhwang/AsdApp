class MchatQuestion {
  final int? id;
  final String questionText;
  final String riskAnswer;
  final int isActive;

  MchatQuestion({
    this.id,
    required this.questionText,
    required this.riskAnswer,
    required this.isActive,
  });

  factory MchatQuestion.fromJson(Map<String, dynamic> json) {
    return MchatQuestion(
      id: json['id'],
      questionText: json['question_text'],
      riskAnswer: json['risk_answer'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_text': questionText,
      'risk_answer': riskAnswer,
      'is_active': isActive,
    };
  }
}
