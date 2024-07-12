class UserDistance {
  final String id;
  final String distance;

  UserDistance({
    required this.id,
    required this.distance,
  });

  factory UserDistance.fromJson(Map<String, dynamic> json) {
    return UserDistance(
      id: json['id'] ?? 'null',
      distance: json['distance'] ?? 'null', 
    );
  }
}
