class UserEntity {
  final int id;
  final String name;
  final String email;
  final String password;
  final int age;
  final String gender;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.age,
    required this.gender,
  });

   // Add a factory constructor for safe creation
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
    );
  }
}
