
import 'package:blog_application/src/features/post/data/models/category_model.dart';
import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';

import 'comment_model.dart';
import 'user_model.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.postId,
    required super.title,
    required super.content,
    required super.imageUrl,
    required super.createAt,
    required super.updateAt,
    super.category,
    required UserModel user,
    required super.comments,
  }) : super(user: user);

  factory PostModel.fromJson(Map<String, dynamic> json) {
    print("🔄 Creating PostModel from JSON: $json");

    try {
      return PostModel(
        postId: json["postId"] as int? ?? 0,
        title: json["title"] as String? ?? "",
        content: json["content"] as String? ?? "",
        imageUrl: json["imageUrl"] as String?,
        createAt: _parseDateTime(json["createAt"]),
        updateAt: _parseDateTime(json["updateAt"]),
        category: json["category"] != null ? CategoryModel.fromJson(json["category"]) : null,
        user: UserModel.fromJson(json["user"] as Map<String, dynamic>? ?? {}),
        comments: (json["comments"] as List<dynamic>? ?? []).map((e) => CommentModel.fromJson(e)).toList(),
      );
    } catch (e, stackTrace) {
      print("❌ ERROR in PostModel.fromJson:");
      print("   - Error: $e");
      print("   - Stack trace: $stackTrace");
      print("   - JSON data: $json");
      rethrow;
    }
  }

  static DateTime _parseDateTime(dynamic dateString) {
    try {
      if (dateString == null) return DateTime.now();
      if (dateString is String) return DateTime.parse(dateString);
      return DateTime.now();
    } catch (e) {
      print("⚠️ Failed to parse date: $dateString, using current time");
      return DateTime.now();
    }
  }

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      postId: entity.postId,
      title: entity.title,
      content: entity.content,
      imageUrl: entity.imageUrl,
      createAt: entity.createAt,
      updateAt: entity.updateAt,
      category: entity.category != null
          ? CategoryModel.fromEntity(entity.category!)
          : null,
      user: UserModel.fromEntity(entity.user),
      comments: entity.comments
          .map((c) => CommentModel.fromEntity(c))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "postId": postId,
      "title": title,
      "content": content,
      "imageUrl": imageUrl,
      "createAt": createAt.toIso8601String(),
      "updateAt": updateAt.toIso8601String(),
      "category": category != null ? (category as CategoryModel).toJson() : null,
      "user": (user as UserModel).toJson(),
      "comments": comments.map((e) => (e as CommentModel).toJson()).toList(),
    };
  }
}