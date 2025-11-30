import 'package:blog_application/src/features/post/data/models/post_model.dart';
import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}


class LoadPostsEvent extends PostEvent {
  final String token;

  const LoadPostsEvent(this.token);
}

class AddPostEvent extends PostEvent {
  final PostModel post;
  final dynamic image; // XFile or Uint8List
  final String token;

  const AddPostEvent({required this.post, required this.image, required this.token});
}

class UpdatePostEvent extends PostEvent { // Add this event
  final int postId;
  final PostEntity post;
  final dynamic image;
  final String token;

  const UpdatePostEvent({
    required this.postId,
    required this.post,
    required this.image,
    required this.token
  });

  @override
  List<Object> get props => [postId, post, token, image ?? ''];
}


class DeletePost extends PostEvent {
  final int postId;
  final String token;

  const DeletePost({required this.postId, required this.token});

@override
  List<Object> get props => [postId, token];
}


class PickImage extends PostEvent {
  final ImageSource source;

  const PickImage(this.source);

  @override
  List<Object> get props => [source];
}