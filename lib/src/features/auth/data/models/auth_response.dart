class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final int? id;
  final String? name;
  final String email;
  final String? password;
  final int? age;
  final String? gender;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.id,
    this.name,
    required this.email,
    this.password,
    this.age,
    this.gender,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      id: json['id'] != null ? json['id'] as int : null,
      name: json['name'] != null ? json['name'] as String : null,
      email: json['email'] ?? '',
      password: json['password'] != null ? json['password'] as String : null,
      age: json['age'] != null ? json['age'] as int : null,
      gender: json['gender'] != null ? json['gender'] as String : null,
    );
  }
}
