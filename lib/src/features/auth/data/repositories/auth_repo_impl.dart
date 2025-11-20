import 'package:blog_application/src/core/storage/local_storage.dart';
import 'package:blog_application/src/features/auth/data/datasources/auth_remote.dart';
import 'package:blog_application/src/features/auth/domain/entities/auth_response_entity.dart';
import 'package:blog_application/src/features/auth/domain/entities/user_entity.dart';
import 'package:blog_application/src/features/auth/domain/repositories/auth_repo.dart';
import 'package:blog_application/src/features/post/data/models/user_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final LocalStorage storage;

  AuthRepositoryImpl(this.remote, this.storage);

  // LOGIN ----------------------------------------------------------
  @override
  Future<AuthResponseEntity> login(String email, String password) async {
    try {
      final response = await remote.login(email, password);

      await storage.saveToken(response.accessToken);
      await storage.saveRefreshToken(response.refreshToken);


      // Since API doesn't return full user info, we use default values
      final user = UserEntity(
        id: response.id!,
        name: response.name!,
        email: response.email,
        password: "", // backend does not send password
        age: response.age!,
        gender: response.gender!,
      );

      // Save user to storage
      await storage.saveUser(UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        password: "",
        age: user.age,
        gender: user.gender,
      ).toJson());

      // Return final auth object
    return AuthResponseEntity(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      user: user,
    );
    } catch (e) {
    throw Exception("Login failed: $e");
  }
  }

// GET VALID TOKEN ------------------------------------------------
  Future<String?> getValidToken() async {
    final token = await storage.getToken();

    if (token != null && !JwtDecoder.isExpired(token)) {
      return token; // still valid
    }

    // token expired → refresh
    final refreshToken = await storage.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final newTokens = await remote.refreshToken(refreshToken);

      // Save new tokens
      await storage.saveToken(newTokens.accessToken);
      await storage.saveRefreshToken(newTokens.refreshToken);

      return newTokens.accessToken;
    } catch (e) {
      print("Refresh token failed: $e");
      return null;
    }
  }

  bool isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }

  @override
  Future<AuthResponseEntity> refreshToken(String refreshToken)async {
    final response = await remote.refreshToken(refreshToken);
    return AuthResponseEntity(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      user: response.user
    );
  }
}
