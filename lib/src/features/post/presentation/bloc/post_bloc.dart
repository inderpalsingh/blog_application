import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_event.dart';
import 'post_state.dart';
import '../../domain/usecases/get_posts_usecase.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPosts;

  PostBloc(this.getPosts) : super(PostInitial()) {
    on<LoadPostsEvent>((event, emit) async {
      emit(PostLoading());
      try {
        final posts = await getPosts();
        emit(PostLoaded(posts));
      } catch (e) {
        emit(PostError(e.toString()));
      }
    });
  }
}
