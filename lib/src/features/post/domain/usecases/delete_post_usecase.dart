import 'package:blog_application/src/core/errors/failures.dart';
import 'package:blog_application/src/features/post/domain/repositories/post_repo.dart';
import 'package:dartz/dartz.dart';

class DeletePostUseCase {
  final PostRepository repository;

  DeletePostUseCase(this.repository);

  Future<Either<Failure, void>> call(DeletePostParams params) async {
    return await repository.deletedPost(
      postId: params.postId,
      token: params.token,
    );
  }
}

class DeletePostParams {
  final int postId;
  final String token;

  DeletePostParams({required this.postId, required this.token});
}