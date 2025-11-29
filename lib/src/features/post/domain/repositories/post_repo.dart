
import 'package:blog_application/src/core/errors/failures.dart';
import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';
import 'package:dartz/dartz.dart';

abstract class PostRepository {
  Future<Either<Failure, List<PostEntity>>> getPosts();

Future<Either<Failure, void>> addPost({
    required PostEntity post,
    required dynamic image, // File on mobile, Uint8List on web
    required String token,
  });


Future<Either<Failure, void>> deletedPost({
  required int postId,
  required String token,
  });


// Add updatePost method following the same pattern
  Future<Either<Failure, PostEntity>> updatePost({
    required int postId,
    required PostEntity post,
    required dynamic image,
  });

}