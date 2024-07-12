class UserItem {
  final String id;
  String name;
  String surname;
  String position;
  final String coordinateX;
  final String coordinateY;
  String email;
  String password;
  final String image;
  String? distance;

  UserItem({
    required this.id,
    required this.name,
    required this.surname,
    required this.position,
    required this.coordinateX,
    required this.coordinateY,
    required this.email,
    required this.password,
    required this.image,
    this.distance,
  });

  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
      id: json['_id'] ?? 'null',
      name: json['name'] ?? 'null', 
      surname: json['surname'] ?? 'null',
      position: json['position'] ?? 'null', 
      coordinateX: json['coordinateX'] ?? 'null', 
      coordinateY: json['coordinateY'] ?? 'null', 
      email: json['email'] ?? 'null',
      password: json['password'] ?? 'null', 
      image: json['url_user_img'] ?? 'null',
      distance: json['distance'] ?? 'null', 
    );
  }
}
