import 'package:blog_application/src/core/errors/failures.dart';
import 'package:blog_application/src/features/post/domain/repositories/post_repo.dart';
import 'package:dartz/dartz.dart';

import '../entities/post_entity.dart';

class AddPostUseCase {
  final PostRepository repository;

  AddPostUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required PostEntity post,
    required dynamic image,
    required String token,
  }) async {
    return await repository.addPost(post: post, image: image, token: token);
  }
}
