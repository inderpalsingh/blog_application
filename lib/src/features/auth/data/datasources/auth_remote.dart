import 'package:blog_application/src/config/env.dart';
import 'package:blog_application/src/core/errors/exceptions.dart';
import 'package:dio/dio.dart';
import '../models/auth_response.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);

  Future<AuthResponse> login(String email, String password) async {
    print("SENDING LOGIN PAYLOAD:");
    print({"username": email, "password": password});
    try {
      final res = await dio.post(Env.baseUrlAuth, data: {"username": email, "password": password});

      print("LOGIN RESPONSE: ${res.data}");
      return AuthResponse.fromJson(res.data);
    } on DioException catch (e) {
      print("LOGIN ERROR STATUS: ${e.response?.statusCode}");
      print("LOGIN ERROR DATA: ${e.response?.data}");

      final msg =
          e.response?.data?["message"] ??
          e.response?.data?["detail"] ??
          e.response?.data?["error"] ??
          e.message ??
          "Login failed";

      throw ServerException(message: msg);
    }
  }
}
