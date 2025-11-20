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

  AddPostEvent({required this.post,required this.image,required this.token});
}
