class UserPercentage {
  final String tag;
  final String percentage;

  UserPercentage({
    required this.tag,
    required this.percentage,
  });

  factory UserPercentage.fromJson(Map<String, dynamic> json) {
    return UserPercentage(
      tag: json['tag'] ?? 'null',
      percentage: json['percentage'] ?? 'null',
    );
  }
}
