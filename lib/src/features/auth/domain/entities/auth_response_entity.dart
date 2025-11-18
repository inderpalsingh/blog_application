import 'package:blog_application/src/features/auth/domain/entities/user_entity.dart';


class AuthResponseEntity {
  final UserEntity user;
  final String accessToken;
  final String refreshToken;

  const AuthResponseEntity({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}
