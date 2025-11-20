import 'package:blog_application/src/features/post/domain/usecases/add_post_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_event.dart';
import 'post_state.dart';
import '../../domain/usecases/get_posts_usecase.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPosts;
  final AddPostUseCase addPost;


  PostBloc({required this.getPosts,required this.addPost}) : super(PostInitial()) {
    on<LoadPostsEvent>((event, emit) async {
      emit(PostLoading());
      try {
        final posts = await getPosts(event.token);
        emit(PostLoaded(posts));
      } catch (e) {
        emit(PostError(e.toString()));
      }
    });

   // Add post
    on<AddPostEvent>((event, emit) async {
      emit(PostLoading());
      try {
        await addPost(
          post: event.post,
          image: event.image,
          token: event.token,
        );

        // Reload posts after adding
        final posts = await getPosts(event.token);
        emit(PostLoaded(posts));

      } catch (e, stack) {
        print("ADD POST ERROR = $e");
        print(stack);
        emit(PostError(e.toString()));
      }
    });
  }
}
