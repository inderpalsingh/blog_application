

import 'package:blog_application/src/features/auth/domain/entities/user_entity.dart';
import 'package:blog_application/src/features/post/domain/entities/category_entity.dart';
import 'package:blog_application/src/features/post/domain/entities/comment_entity.dart';

class PostEntity {
  final int postId;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime createAt;
  final DateTime updateAt;
  final CategoryEntity? category;
  final UserEntity user;
  final List<CommentEntity> comments;

  const PostEntity({
    required this.postId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.createAt,
    required this.updateAt,
    this.category,
    required this.user,
    required this.comments,
  });






}
