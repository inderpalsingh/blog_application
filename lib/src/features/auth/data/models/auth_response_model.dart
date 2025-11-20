import 'package:blog_application/src/features/auth/domain/entities/auth_response_entity.dart';
import 'package:blog_application/src/features/post/data/models/user_model.dart';


class AuthResponseModel extends AuthResponseEntity {
  AuthResponseModel({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) : super(
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: user,
        );

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
      user: UserModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        password: "",
        age: json["age"],
        gender: json["gender"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "user": (user as UserModel).toJson(),
    };
  }
}