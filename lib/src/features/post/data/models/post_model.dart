
import 'package:blog_application/src/features/auth/domain/entities/user_entity.dart';
import 'package:blog_application/src/features/post/data/models/category_model.dart';
import 'package:blog_application/src/features/post/data/models/comment_model.dart';
import 'package:blog_application/src/features/post/data/models/user_model.dart';
import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';


class PostModel extends PostEntity {
  const PostModel({
    required super.postId,
    required super.title,
    required super.content,
    required super.imageUrl,
    required super.createAt,
    required super.updateAt,
    required super.category,
    required UserEntity user,
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
      category: CategoryModel.fromJson(json["category"]),
      user: UserModel.fromJson(json["user"]), // WORKS NOW
      comments: (json["comments"] as List)
          .map((e) => CommentModel.fromJson(e))
          .toList(),
    );
  }
}