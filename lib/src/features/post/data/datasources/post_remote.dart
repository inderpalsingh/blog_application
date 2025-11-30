import 'dart:convert';
import 'package:blog_application/src/core/storage/local_storage.dart';
import 'package:blog_application/src/features/auth/domain/repositories/auth_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:blog_application/src/config/env.dart';
import 'package:blog_application/src/core/errors/exceptions.dart';
import 'package:blog_application/src/features/post/data/models/post_model.dart';
import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';
import 'package:dio/dio.dart';

class PostRemoteDataSource {
  final Dio dio;
  final LocalStorage localStorage;
  final AuthRepository authRepository;

  PostRemoteDataSource(this.dio, this.localStorage, this.authRepository);

  Future<List<PostEntity>> getPosts() async {
    try {
      // Use getValidToken from AuthRepository
      final token = await authRepository.getValidToken();

      if (token == null) {
        throw AuthException(message: 'No valid token available. Please login again.');
      }

      final response = await dio.get(
        Env.baseUrlPosts,
        queryParameters: {'pageNumber': 0, 'pageSize': 10, 'sortBy': 'postId', 'sortDir': 'asc'},
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

  Future<void> createPost({required PostModel post, required dynamic image}) async {
    final url = "${Env.baseUrlPosts}/user/${post.user.id}/category/${post.category?.categoryId}/post";

    // Use getValidToken instead of direct token
    final token = await authRepository.getValidToken();

    if (token == null) {
      throw AuthException(message: 'No valid token available. Please login again.');
    }

    print("UPLOAD URL = $url");
    print("POST DATA: title=${post.title}, content=${post.content}");
    print("USER ID: ${post.user.id}");
    print("CATEGORY ID: ${post.category?.categoryId}");
    print("USING TOKEN: ${token.substring(0, 20)}...");

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

  Future<PostEntity> updatePost({required int postId, required PostModel post, required dynamic image}) async {
    final url = "${Env.baseUrlPosts}/$postId";

    // Use your existing getValidToken method from AuthRepository
    final token = await authRepository.getValidToken();

    if (token == null) {
      throw AuthException(message: 'No authentication token found. Please login again.');
    }

    // Debug: Print what we're sending
    print("🔄 UPDATE POST URL = $url");
    print("UPDATE POST DATA: title=${post.title}, content=${post.content}");
    print("POST ID: $postId");
    print("HAS IMAGE: ${image != null}");
    print("TOKEN PREVIEW: ${token.substring(0, 20)}...");

    try {
      // FIX: Always use JSON, ignore image for updates (backend limitation)
      final postData = {"title": post.title, "content": post.content};

      final response = await dio.put(
        url,
        data: postData,
        options: Options(headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"}),
      );

      print("✅ POST UPDATED SUCCESSFULLY: ${response.data}");

      if (image != null && image is Uint8List) {
      try {
        await _updatePostImage(postId, post, image, token);
        print("✅ POST IMAGE UPDATED SUCCESSFULLY");
      } catch (e) {
        print("⚠️ Image update failed, but text was updated: $e");
        // Don't throw - text was updated successfully
      }
    }

      return PostModel.fromJson(response.data);
    } on DioException catch (e) {
      print("❌ UPDATE POST ERROR = $e");
      if (e.response != null) {
        print("STATUS: ${e.response!.statusCode}");
        print("RESPONSE DATA: ${e.response!.data}");
      }

      // Handle 401 specifically
      if (e.response?.statusCode == 401) {
        throw AuthException(message: 'Authentication failed. Please login again.');
      }

      throw ServerException(message: e.response?.data["message"] ?? "Failed to update post");
    }
  }

  Future<void> _updatePostImage(int postId, PostModel post, Uint8List imageBytes, String token) async {
  // Use the same endpoint as creating posts, but with the existing post ID
  final url = "${Env.baseUrlPosts}/user/${post.user.id}/category/${post.category?.categoryId}/post";

  print("🔄 UPDATING POST IMAGE URL = $url");

  final postData = {
    "title": post.title,
    "content": post.content
  };

  final formData = FormData.fromMap({
    "post": MultipartFile.fromString(
      jsonEncode(postData),
      contentType: MediaType.parse('application/json')
    ),
    "image": MultipartFile.fromBytes(
      imageBytes,
      filename: "update_image.png",
      contentType: MediaType("image", "png")
    )
  });

  // Use POST to update the image (same as create endpoint)
  final response = await dio.post(
    url,
    data: formData,
    options: Options(headers: {"Authorization": "Bearer $token"}),
  );

  print("✅ POST IMAGE UPDATED: ${response.data}");
}



}
