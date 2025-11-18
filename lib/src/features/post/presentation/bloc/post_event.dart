abstract class PostEvent {}

class LoadPostsEvent extends PostEvent {
  final String token;

  LoadPostsEvent(this.token);
}
