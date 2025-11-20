import 'package:blog_application/src/features/post/domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({required int id, required String comments, DateTime? createdAt}) : super(id: id, comments: comments, createdAt: createdAt);

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: json["commentId"], // map JSON "commentId" to id
    comments: json["content"], // map JSON "content" to comments
    createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
  );

  Map<String, dynamic> toJson() {
    return {"commentId": id, "content": comments, "createdAt": createdAt?.toIso8601String()};
  }
}
