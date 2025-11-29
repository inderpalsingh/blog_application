import 'package:blog_application/src/core/errors/failures.dart';
import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';
import 'package:dartz/dartz.dart';

import '../repositories/post_repo.dart';

class GetPostsUseCase {
  final PostRepository repository;
  GetPostsUseCase(this.repository);

  Future<Either<Failure, List<PostEntity>>> call() async{
    return await repository.getPosts();
  }
}
