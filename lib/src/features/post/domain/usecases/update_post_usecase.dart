import 'package:blog_application/src/core/errors/failures.dart';
import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';
import 'package:blog_application/src/features/post/domain/repositories/post_repo.dart';
import 'package:dartz/dartz.dart';

class UpdatePostUseCase {
  final PostRepository repository;

  UpdatePostUseCase(this.repository);

  // If returning void
  Future<Either<Failure, PostEntity>> call({required int postId, required PostEntity post, required dynamic image,}) async {
    return await repository.updatePost(postId: postId, post: post, image: image);
  }
}

// int postId,PostEntity post, dynamic image,String token
