import 'package:blog_application/src/features/auth/domain/entities/auth_response_entity.dart';

abstract class AuthRepository {
  Future<AuthResponseEntity> login(String email, String password);
  Future<AuthResponseEntity> refreshToken(String refreshToken);
  Future<String?> getValidToken(); // Add this
  bool isTokenExpired(String token); // Add this
}