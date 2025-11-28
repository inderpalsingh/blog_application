import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:blog_application/src/config/env.dart';
import 'package:blog_application/src/core/errors/exceptions.dart';
import 'package:blog_application/src/features/post/data/models/post_model.dart';
import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';
import 'package:dio/dio.dart';

class PostRemoteDataSource {
  final Dio dio;

  PostRemoteDataSource(this.dio);

  Future<List<PostEntity>> getPosts(String token) async {
    try {
      // final response = await dio.get("${Env.baseUrlPosts}?pageNumber=0&pageSize=10&sortBy=createAt&sortDir=asc",
      final response = await dio.get(Env.baseUrlPosts, queryParameters: {
        'pageNumber': 0, 'pageSize': 10, 'sortBy': 'createAt', 'sortDir': 'asc'
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print("POSTS URL = ${Env.baseUrlPosts}");
      print("response.data = ${response.data}");

      final content = response.data["content"] as List;
      return content.map((e) => PostModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data["message"] ?? "Failed to fetch posts");
    }
  }

  Future<void> createPost({required PostModel post, required dynamic image, required String token}) async {
    final url = "${Env.baseUrlPosts}/user/${post.user.id}/category/${post.category?.categoryId}/post";
    print("UPLOAD URL = $url");

    // Debug: Print what we're sending
    print("POST DATA: title=${post.title}, content=${post.content}");
    print("USER ID: ${post.user.id}");
    print("CATEGORY ID: ${post.category?.categoryId}");

    final postData = {"title": post.title, "content": post.content};

    final formData = FormData.fromMap({"post": MultipartFile.fromString(jsonEncode(postData), contentType: MediaType.parse('application/json')), if (image != null) "image": kIsWeb ? MultipartFile.fromBytes(image, filename: "upload_image.png", contentType: MediaType("image", "png")) : await MultipartFile.fromFile(image.path, filename: image.path.split("/").last)});

    // Add interceptor to see the actual request
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true, requestHeader: true));

    try {
      final response = await dio.post(
        url,
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      print("POST CREATED SUCCESSFULLY: ${response.data}");
    } on DioException catch (e) {
      print("ADD POST ERROR = $e");
      if (e.response != null) {
        print("STATUS: ${e.response!.statusCode}");
        print("RESPONSE DATA: ${e.response!.data}");
      }
      rethrow;
    }
  }

  Future<void> deletePost({required String token, required int postId}) async {
    final url = "${Env.baseUrlPosts}/$postId";
    print("DELETE URL = $url");
    print("TOKEN BEING SENT: $token");

    try {
      final response = await dio.delete(url, options: Options(headers: {"Authorization": "Bearer $token"}));
      if (response.statusCode == 200 || response.statusCode == 204) {
        print("POST DELETED SUCCESSFULLY");
      } else {
        print("DELETE FAILED: ${response.statusCode}");
        throw ServerException(message: "Failed to delete post");
      }
    } on DioException catch (e) {
      print("DELETE POST ERROR = $e");
      if (e.response != null) {
        print("STATUS: ${e.response!.statusCode}");
        print("RESPONSE DATA: ${e.response!.data}");
      }
      throw ServerException(message: e.response?.data["message"] ?? "Failed to delete post");
    }
  }
}
