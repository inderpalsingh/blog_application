import 'package:blog_application/src/features/post/domain/repositories/post_repo.dart';

class DeletePostUseCase {
  final PostRepository repository;

  DeletePostUseCase(this.repository);

  Future<void> call(DeletePostParams params) async {
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