class ChatMessage {
  final String question;
  String? answer;
  final DateTime time;

  ChatMessage({required this.question, this.answer, required this.time});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      question: json['question'],
      answer: json['ai_response'],
      time: DateTime.parse(json['created_at']),
    );
  }
}
