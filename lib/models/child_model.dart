class ChildModel {
  final int id;
  final String fullName;
  final String? birthDate;
  final String? gender;
  final String? guardianName;
  final int userId;

  ChildModel({
    required this.id,
    required this.fullName,
    this.birthDate,
    this.gender,
    this.guardianName,
    required this.userId,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      birthDate: json['birth_date'],
      gender: json['gender'],
      guardianName: json['guardian_name'],
      userId: json['user_id'],
    );
  }
}
