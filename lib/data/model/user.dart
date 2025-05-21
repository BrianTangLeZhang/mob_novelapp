class User {
  int? id;
  final String username;
  final String email;
  final String password;
  final String role;

  static const name = "users";

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.role = "User",
  });

  User copy({
    int? id,
    String? username,
    String? email,
    String? password,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, password: $password, role: $role)';
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
    );
  }
}
