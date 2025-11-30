import 'package:blog_application/src/features/post/domain/usecases/add_post_usecase.dart';
import 'package:blog_application/src/features/post/domain/usecases/delete_post_usecase.dart';
import 'package:blog_application/src/features/post/domain/usecases/update_post_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'post_event.dart';
import 'post_state.dart';
import '../../domain/usecases/get_posts_usecase.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPosts;
  final AddPostUseCase addPost;
  final DeletePostUseCase deletePostUseCase;
  final UpdatePostUseCase updatePost;
  final ImagePicker imagePicker;

  PostBloc({
    required this.getPosts,
    required this.addPost,
    required this.deletePostUseCase,
    required this.updatePost,
  }) : imagePicker = ImagePicker(), super(PostInitial()) {

    on<LoadPostsEvent>(_onLoadPosts);
    on<AddPostEvent>(_onAddPost);
    on<DeletePost>(_onDeletePost);
    on<UpdatePostEvent>(_onUpdatePost);
    on<PickImage>(_onPickImage);
  }

  void _onLoadPosts(LoadPostsEvent event, Emitter<PostState> emit) async {
  emit(PostLoading());

  final result = await getPosts(); // This returns Either<Failure, List<PostEntity>>

  result.fold(
    // Failure case
    (failure) => emit(PostError(failure.message)),
    // Success case
    (posts) => emit(PostsLoaded(posts)), // posts is already List<PostEntity>
  );
}

  void _onPickImage(PickImage event, Emitter<PostState> emit) async {
    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: event.source,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        emit(ImagePicked(bytes, pickedFile.name));
      }
    } catch (e) {
      emit(PostError('Failed to pick image: $e'));
    }
  }

  void _onAddPost(AddPostEvent event, Emitter<PostState> emit) async {
    emit(PostLoading());
    try {
      final result = await addPost.call(
        post: event.post,
        image: event.image,
        token: event.token,
      );


      // Reload posts after adding
      result.fold(
        // Failure case
        (failure) => emit(PostError(failure.message)),
        // Success case - void means success
        (_) {
          // Post added successfully, reload posts or update state
          add(LoadPostsEvent(event.token)); // Trigger reload of posts
        },
      );
    } catch (e, stack) {
      print("ADD POST ERROR = $e");
      print(stack);
      emit(PostError(e.toString()));
    }
  }

  void _onDeletePost(DeletePost event, Emitter<PostState> emit) async {
    if (state is PostsLoaded) {
      final currentState = state as PostsLoaded;
      try {
        // Call the API to delete the post
        await deletePostUseCase(DeletePostParams(postId: event.postId, token: event.token));

        // Remove locally after successful API call
        final updatedPosts = currentState.posts.where((post) => post.postId != event.postId).toList();
        emit(PostsLoaded(updatedPosts));
      } catch (e) {
        // Check if it's an unauthorized error
        if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
          // Token is invalid - trigger logout or token refresh
          print("🔄 Token expired or invalid, redirecting to login");
          emit(PostError("Session expired. Please login again."));
        } else {
          emit(PostError("Failed to delete post: ${e.toString()}"));
        }
      }
    }
  }

  void _onUpdatePost(UpdatePostEvent event, Emitter<PostState> emit) async {
    emit(PostLoading());
    try {
      final result = await updatePost(
        postId: event.postId,
        post: event.post,
        image: event.image,
      );

      result.fold(
        (failure) => emit(PostError(failure.toString())),
        (updatedPost) {
          // Show update success
          emit(PostUpdated(updatedPost));

          // Reload all posts to get the latest data from server
          add(LoadPostsEvent(event.token));
        },
      );
    } catch (e) {
        // Check if it's an unauthorized error
        if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
          // Token is invalid - trigger logout or token refresh
          print("🔄 Token expired or invalid, redirecting to login");
          emit(PostError("Session expired. Please login again."));
        } else {
          emit(PostError("Failed to delete post: ${e.toString()}"));
        }
      }
  }
}