import 'package:blog_application/src/config/env.dart';
import 'package:blog_application/src/core/errors/exceptions.dart';
import 'package:blog_application/src/features/post/data/models/post_model.dart';
import 'package:blog_application/src/features/post/domain/post_entity.dart';
import 'package:dio/dio.dart';

class PostRemoteDataSource {
  final Dio dio;

  PostRemoteDataSource(this.dio);

  Future<List<PostEntity>> getPosts() async {
    try {
      final response = await dio.get("${Env.baseUrl}/api/posts");

      final content = response.data["content"] as List;

      return content.map((e) => PostModel.fromJson(e)).toList();

    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data["message"] ?? "Failed to fetch posts",
      );
    }
  }
}
