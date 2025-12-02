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


    final token = await authRepository.getValidToken();
    print("TOKEN BEING SENT: $token");


    if (token == null) {
      throw AuthException(message: 'No authentication token found. Please login again.');
    }

    try {
      final response = await dio.delete(url, options: Options(
        headers: {"Authorization": "Bearer $token"}
        ));
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
    final token = await authRepository.getValidToken();

    if (token == null) {
      throw AuthException(message: 'No authentication token found. Please login again.');
    }

    print("🔄 UPDATE POST - ID: $postId, Title: ${post.title}, Has Image: ${image != null}");

    try {
      // Create FormData for multipart request
      FormData formData = FormData.fromMap({
        // This must be a JSON string with key "post" (matching @RequestPart("post"))
        'post': jsonEncode({'title': post.title, 'content': post.content}),
      });

      // Add image if provided
      if (image != null && image is Uint8List) {
        formData.files.add(
          MapEntry(
            'image', // This must match @RequestPart("image")
            MultipartFile.fromBytes(image, filename: 'post_image_${DateTime.now().millisecondsSinceEpoch}.png'),
          ),
        );
      }

      // Send the multipart PUT request
      final response = await dio.put(
        url,
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            // DO NOT set Content-Type header - Dio will automatically set it to multipart/form-data
          },
        ),
      );

      print("✅ POST UPDATED SUCCESSFULLY: ${response.data}");
      return PostModel.fromJson(response.data);
    } on DioException catch (e) {
      print("❌ UPDATE POST ERROR = $e");
      if (e.response != null) {
        print("STATUS: ${e.response!.statusCode}");
        print("RESPONSE DATA: ${e.response!.data}");
        print("REQUEST HEADERS: ${e.requestOptions.headers}");
        print("REQUEST DATA TYPE: ${e.requestOptions.data.runtimeType}");

        // Debug: Print what we're actually sending
        if (e.requestOptions.data is FormData) {
          FormData fd = e.requestOptions.data as FormData;
          print("FormData fields: ${fd.fields}");
          print("FormData files: ${fd.files.length}");
        }
      }

      if (e.response?.statusCode == 401) {
        throw AuthException(message: 'Authentication failed. Please login again.');
      }

      throw ServerException(message: e.response?.data["message"] ?? "Failed to update post: ${e.message}");
    }
  }

}
