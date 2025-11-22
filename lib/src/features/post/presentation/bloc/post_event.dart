import 'package:blog_application/src/features/post/data/models/post_model.dart';

abstract class PostEvent {}

class LoadPostsEvent extends PostEvent {
  final String token;

  LoadPostsEvent(this.token);
}

class AddPostEvent extends PostEvent {
  final PostModel post;
  final dynamic image; // XFile or Uint8List
  final String token;

  AddPostEvent({required this.post, required this.image, required this.token});
}

class DeletePost extends PostEvent {
  final int postId;
  final String token;

  DeletePost({required this.postId, required this.token});

  List<Object> get props => [postId, token];
}
