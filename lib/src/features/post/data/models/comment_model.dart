import 'package:blog_application/src/features/post/domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required int id,
    required String comments,
    DateTime? createdAt,
  }) : super(
          id: id,
          comments: comments,
          createdAt: createdAt,
        );

  /// Convert JSON → CommentModel
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json["commentId"],       // Backend uses commentId
      comments: json["content"],   // Backend uses content
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
    );
  }

  /// Convert Entity → Model
  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      comments: entity.comments,
      createdAt: entity.createdAt,
    );
  }

  /// Convert Model → JSON
  Map<String, dynamic> toJson() {
    return {
      "commentId": id,
      "content": comments,
      "createdAt": createdAt?.toIso8601String(),
    };
  }
}