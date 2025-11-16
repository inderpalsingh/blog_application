
import 'package:blog_application/src/features/post/data/models/category_model.dart';
import 'package:blog_application/src/features/post/data/models/comment_model.dart';
import 'package:blog_application/src/features/post/data/models/user_model.dart';
import 'package:blog_application/src/features/post/domain/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required int postId,
    required String title,
    required String content,
    required String? imageUrl,
    required DateTime createAt,
    required DateTime updateAt,
    required CategoryModel category,
    required UserModel user,
    required List<CommentModel> comments,
  }) : super(
          postId: postId,
          title: title,
          content: content,
          imageUrl: imageUrl,
          createAt: createAt,
          updateAt: updateAt,
          category: category,
          user: user,        // ✅ now passes UserModel as UserEntity correctly
          comments: comments,
        );

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json["postId"],
      title: json["title"],
      content: json["content"],
      imageUrl: json["imageUrl"],
      createAt: DateTime.parse(json["createAt"]),
      updateAt: DateTime.parse(json["updateAt"]),
      category: CategoryModel.fromJson(json["category"]),
      user: UserModel.fromJson(json["user"]),
      comments: (json["comments"] as List)
          .map((e) => CommentModel.fromJson(e))
          .toList(),
    );
  }
}
