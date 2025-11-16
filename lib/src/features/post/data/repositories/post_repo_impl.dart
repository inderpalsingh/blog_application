
import 'package:blog_application/src/features/post/domain/post_entity.dart';

import '../../domain/repositories/post_repo.dart';
import '../datasources/post_remote.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remote;

  PostRepositoryImpl(this.remote);

  @override
  Future<List<PostEntity>> getPosts() async {
    return remote.getPosts();
  }
}
