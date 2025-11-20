import 'package:blog_application/src/features/post/domain/repositories/post_repo.dart';

import '../entities/post_entity.dart';

class AddPostUseCase {
  final PostRepository repository;

  AddPostUseCase(this.repository);

  Future<void> call({
    required PostEntity post,
    required dynamic image,
    required String token,
  }) async {
    await repository.addPost(post: post, image: image, token: token);
  }
}
