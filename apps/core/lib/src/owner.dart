class User {
  final String id;
  final String name;
  final String email;
  final String? picture;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.picture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['displayName'] as String,
      email: json['loginName'] as String,
      picture: json['profilePicUrl'] as String?,
    );
  }
}
