
import 'package:blog_application/src/features/post/domain/post_entity.dart';

abstract class PostRepository {
  Future<List<PostEntity>> getPosts();
}
