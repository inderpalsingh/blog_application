import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';

import '../repositories/post_repo.dart';

class GetPostsUseCase {
  final PostRepository repository;
  GetPostsUseCase(this.repository);

  Future<List<PostEntity>> call(String token){
    return repository.getPosts(token);
  }
}
