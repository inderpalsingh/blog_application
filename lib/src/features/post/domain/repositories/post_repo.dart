
import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';

abstract class PostRepository {
  Future<List<PostEntity>> getPosts(String token);

Future<void> addPost({
    required PostEntity post,
    required dynamic image, // File on mobile, Uint8List on web
    required String token,
  });


Future<void> deletedPost({
  required int postId,
  required String token,
  });
}
