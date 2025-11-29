

import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';
import 'package:equatable/equatable.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostsLoaded extends PostState { // Add this state
  final List<PostEntity> posts;

  const PostsLoaded(this.posts);

  @override
  List<Object> get props => [posts];
}


class PostError extends PostState {
  final String message;
  const PostError(this.message);
}


class PostOperationFailure extends PostState {
  final String error;

  const PostOperationFailure(this.error);

  @override
  List<Object> get props => [error];
}


class PostUpdated extends PostState {
  final PostEntity post;

  const PostUpdated(this.post);

  @override
  List<Object> get props => [post];
}

class ImagePicked extends PostState {
  final List<int> imageBytes;
  final String fileName;

  const ImagePicked(this.imageBytes, this.fileName);

  @override
  List<Object> get props => [imageBytes, fileName];
}