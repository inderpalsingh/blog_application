
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
    return PostModel(
      postId: json["postId"],
      title: json["title"],
      content: json["content"],
      imageUrl: json["imageUrl"],
      createAt: DateTime.parse(json["createAt"]),
      updateAt: DateTime.parse(json["updateAt"]),
      category: json["category"] != null ? CategoryModel.fromJson(json["category"]) : null,
      user: UserModel.fromJson(json["user"]),
      comments: (json["comments"] as List).map((e) => CommentModel.fromJson(e)).toList(),
    );
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