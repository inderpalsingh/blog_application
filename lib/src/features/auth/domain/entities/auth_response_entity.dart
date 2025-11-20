

import 'package:blog_application/src/features/auth/domain/entities/user_entity.dart';

class AuthResponseEntity {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;

  AuthResponseEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}
