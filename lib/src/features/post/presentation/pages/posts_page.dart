import 'dart:typed_data';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:blog_application/src/features/post/data/models/post_model.dart';
import 'package:blog_application/src/features/post/presentation/pages/AddPostBottomSheet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

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
    final dio = Dio(BaseOptions(baseUrl: 'http://192.168.29.200:10000'));

    Future<void> uploadPost(PostModel post, dynamic image) async {
      FormData formData = FormData();

      if (image != null) {
        formData.files.add(MapEntry('image', kIsWeb ? MultipartFile.fromBytes(image as Uint8List, filename: 'upload.jpg') : await MultipartFile.fromFile((image as XFile).path, filename: 'upload.jpg')));
      }

      formData.fields.add(MapEntry('post', post.toJson().toString()));

      final response = await dio.post(
        '/api/posts/user/$userId/category/$categoryId/post',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print("Upload response: ${response.data}");
    }

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
