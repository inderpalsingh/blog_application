import 'package:blog_application/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:blog_application/src/features/post/data/models/post_model.dart';
import 'package:blog_application/src/features/post/presentation/pages/AddPostBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../bloc/post_state.dart';

class PostsPage extends StatelessWidget {
  final String token;
  final int? userId;
  final int? categoryId;

  const PostsPage({super.key, required this.token, this.userId, this.categoryId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => context.read<PostBloc>()..add(LoadPostsEvent(token)),
      child: Scaffold(
        appBar: AppBar(title: const Text("All Posts")),
        body: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state is PostLoading) return const Center(child: CircularProgressIndicator());
            if (state is PostError) return Center(child: Text(state.message));

            if (state is PostLoaded) {

              return ListView.builder(
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return ListTile(

                    title: Text(post.title),
                    subtitle: Text(post.content),
                    leading: post.imageUrl != null ? Image.network(post.imageUrl!, width: 50, height: 50, fit: BoxFit.cover) : const Icon(Icons.image_not_supported),
                    trailing: IconButton(
                      onPressed: () {
                        context.read<PostBloc>().add(
                          DeletePost(postId: post.postId, token: token)
                        );
                      }, icon: Icon(Icons.delete),
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton.small(
          child: const Icon(Icons.add),
          onPressed: () async {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthSuccess && authState.user != null) {
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                builder: (context) => AddPostBottomSheet(currentUser: authState.user!),
              );

              if (result != null) {
                final newPost = result['post'] as PostModel;
                final image = result['image'];

                // Dispatch AddPostEvent to PostBloc
                final postBloc = context.read<PostBloc>();
                postBloc.add(AddPostEvent(post: newPost, image: image, token: authState.accessToken));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post added successfully")));
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must be logged in to add a post")));
            }
          },
        ),
      ),
    );
  }
}
