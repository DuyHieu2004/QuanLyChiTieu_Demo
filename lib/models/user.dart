class User {
  int? id;
  String username;
  String password;
  String? fullName;
  String? gender;
  String? illustration; // Path to image or identifier

  User({
    this.id,
    required this.username,
    required this.password,
    this.fullName,
    this.gender,
    this.illustration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullName': fullName,
      'gender': gender,
      'illustration': illustration,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      fullName: map['fullName'],
      gender: map['gender'],
      illustration: map['illustration'],
    );
  }
}