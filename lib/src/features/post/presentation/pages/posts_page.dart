import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../bloc/post_state.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => context.read<PostBloc>()..add(LoadPostsEvent()),
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
                    leading: post.imageUrl != null
                        ? Image.network(post.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.image_not_supported),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
