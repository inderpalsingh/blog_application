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

  PostRemoteDataSource(this.dio,this.localStorage,this.authRepository);

  Future<List<PostEntity>> getPosts() async {
    try {

      // Use getValidToken from AuthRepository
      final token = await authRepository.getValidToken();

      if (token == null) {
        throw AuthException(message: 'No valid token available. Please login again.');
      }

      final response = await dio.get(Env.baseUrlPosts,queryParameters: {'pageNumber': 0, 'pageSize': 10, 'sortBy': 'postId', 'sortDir': 'asc'},
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
  print("TOKEN: $token"); // Add this to verify token is present

  try {
    // First approach: Try with JSON body (without image)
    if (image == null) {
      // If no image, send as JSON
      final postData = {"title": post.title, "content": post.content};

      final response = await dio.put(
        url,
        data: postData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      print("✅ POST UPDATED SUCCESSFULLY (JSON): ${response.data}");
      return PostModel.fromJson(response.data);
    } else {
      // If there's an image, we need to handle it differently
      // Option 1: Use PATCH instead of PUT
      return await _updatePostWithImage(url, postId, post, image, token);
    }
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

  // Helper method for updating post with image - also return PostEntity
  Future<PostEntity> _updatePostWithImage(String url,int postId,PostModel post,dynamic image,String token) async {
    try {
      // Try PATCH request first
      final postData = {"title": post.title, "content": post.content};

      final formData = FormData.fromMap({"post": MultipartFile.fromString(jsonEncode(postData), contentType: MediaType.parse('application/json')), if (image != null) "image": kIsWeb ? MultipartFile.fromBytes(image, filename: "update_image.png", contentType: MediaType("image", "png")) : await MultipartFile.fromFile(image.path, filename: image.path.split("/").last)});

      final response = await dio.patch(
        url,
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      print("✅ POST UPDATED SUCCESSFULLY (PATCH): ${response.data}");
      return PostModel.fromJson(response.data); // RETURN
    } on DioException catch (e) {
      // If PATCH fails, try separate calls
      if (e.response?.statusCode == 405 || e.response?.statusCode == 415) {
        print("🔄 PATCH not supported, trying separate update calls...");
        return await _updatePostSeparateCalls(url, postId, post, image, token); // RETURN
      } else {
        rethrow;
      }
    }
  }

  // Update post and image separately - return PostEntity
  Future<PostEntity> _updatePostSeparateCalls(
    // Change return type
    String url,
    int postId,
    PostModel post,
    dynamic image,
    String token,
  ) async {
    // First update the post text content
    final postData = {"title": post.title, "content": post.content};

    final updateResponse = await dio.put(
      url,
      data: postData,
      options: Options(headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"}),
    );

    print("✅ POST CONTENT UPDATED: ${updateResponse.data}");

    // Then update the image separately if provided
    if (image != null) {
      await _updatePostImageOnly(url, postId, image, token);
    }

    return PostModel.fromJson(updateResponse.data); // RETURN the updated post
  }

  Future<void> _updatePostImageOnly(String url, int postId, dynamic image, String token) async {
    final imageUrl = "$url/image"; // Try common endpoint for image update
    // Or use the same URL with different method
    // final imageUrl = url;

    try {
      final formData = FormData.fromMap({"image": kIsWeb ? MultipartFile.fromBytes(image, filename: "update_image.png", contentType: MediaType("image", "png")) : await MultipartFile.fromFile(image.path, filename: image.path.split("/").last)});

      final response = await dio.patch(
        // Try PATCH for image
        imageUrl,
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      print("✅ POST IMAGE UPDATED: ${response.data}");
    } on DioException catch (e) {
      print("⚠️ Could not update image: $e");
      // Continue without throwing - the text content was updated successfully
    }
  }
}
