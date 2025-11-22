import 'package:blog_application/src/features/post/data/models/post_model.dart';
import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';

import '../../domain/repositories/post_repo.dart';
import '../datasources/post_remote.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remote;

  PostRepositoryImpl(this.remote);

  @override
  Future<List<PostEntity>> getPosts(String token) async {
    return await remote.getPosts(token);
  }

  @override
  Future<void> addPost({required PostEntity post, required image, required String token}) async {
    await remote.createPost(post: post as PostModel, image: image, token: token);
  }

  @override
  Future<void> deletedPost({required int postId, required String token}) async {
    return await remote.deletePost(postId: postId, token: token);
  }
}
