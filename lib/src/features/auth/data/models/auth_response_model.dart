import 'package:blog_application/src/features/auth/domain/entities/auth_response_entity.dart';

import 'package:blog_application/src/features/post/data/models/user_model.dart';

class AuthResponseModel extends AuthResponseEntity {
  const AuthResponseModel({
    required super.accessToken,
    required super.refreshToken,
    required super.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
      user: UserModel.fromJson(json["user"]),
    );
  }
}
