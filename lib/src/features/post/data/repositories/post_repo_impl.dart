
import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';

import '../../domain/repositories/post_repo.dart';
import '../datasources/post_remote.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remote;

  PostRepositoryImpl(this.remote);

  @override
  Future<List<PostEntity>> getPosts(String token) async {
    return remote.getPosts(token);
  }
}
