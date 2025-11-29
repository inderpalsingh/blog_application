import 'package:blog_application/src/core/errors/exceptions.dart';
import 'package:blog_application/src/core/errors/failures.dart';
import 'package:blog_application/src/core/storage/local_storage.dart';
import 'package:blog_application/src/features/post/data/models/post_model.dart';
import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';
import 'package:dartz/dartz.dart';
import '../../domain/repositories/post_repo.dart';
import '../datasources/post_remote.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final LocalStorage localStorage;

  PostRepositoryImpl(this.remoteDataSource, this.localStorage);

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts() async {
    try {
      final posts = await remoteDataSource.getPosts();
      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addPost({required PostEntity post, required image, required String token}) async {
    try {
      // Convert PostEntity to PostModel
      await remoteDataSource.createPost(
        post: post as PostModel, // or convert to PostModel
        image: image,
        token: token
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletedPost({required int postId, required String token}) async {
    try {
      await remoteDataSource.deletePost(token: token, postId: postId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> updatePost({required int postId, required PostEntity post, required image}) async {
    try {
      // Convert PostEntity to PostModel
      final postModel = PostModel.fromEntity(post);

      final updatedPost = await remoteDataSource.updatePost(
      postId: postId,
      post: postModel,
      image: image
    );
      print("✅ Repository: Post updated successfully");
      return Right(updatedPost);
    } on ServerException catch (e) {
      print("❌ Repository: Server error updating post: ${e.message}");
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      print("❌ Repository: Auth error updating post: ${e.message}");
      return Left(AuthFailure(e.message));
    } catch (e) {
      print("❌ Repository: Unexpected error updating post: $e");
      return Left(ServerFailure(e.toString()));
    }
  }
}
