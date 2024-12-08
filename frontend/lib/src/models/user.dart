class User {
  final String username;
  final String email;
  final String role;

  User({
    required this.username,
    required this.email,
    required this.role,
  });

  // Convert JSON to User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'role': role,
    };
  }
}
