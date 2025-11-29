import 'package:blog_application/src/core/storage/local_storage.dart';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:blog_application/src/features/post/data/models/post_model.dart';
import 'package:blog_application/src/features/post/data/models/user_model.dart';
import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';
import 'package:blog_application/src/features/post/presentation/pages/AddPostBottomSheet.dart';
import 'package:blog_application/src/features/post/presentation/pages/edit_post_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../bloc/post_state.dart';

class PostsPage extends StatelessWidget {
  final String token;
  final int? userId;
  final int? categoryId;
  final LocalStorage storage = LocalStorage();

  PostsPage({super.key, required this.token, this.userId, this.categoryId});

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

      if (state is PostsLoaded) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<PostBloc>().add(LoadPostsEvent(token));
            await Future.delayed(Duration(seconds: 1));
          },
          child: ListView.builder(
            itemCount: state.posts.length,
            itemBuilder: (context, index) {
              final post = state.posts[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    post.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.content.length > 100
                            ? '${post.content.substring(0, 100)}...'
                            : post.content,
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Posted on: ${DateFormat('MMM dd, yyyy').format(post.createAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  leading: post.imageUrl != null
                      ? Container(
                          width: 60,
                          height: 60,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              post.imageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.broken_image, color: Colors.grey);
                              },
                            ),
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.article, color: Colors.grey[600]),
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      IconButton(
                        onPressed: () {
                          _navigateToEditPage(context, post, token);
                        },
                        icon: Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Edit Post',
                      ),
                      // Delete Button
                      IconButton(
                        onPressed: () {
                          _showDeleteDialog(context, post.postId, token);
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Post',
                      ),
                    ],
                  ),
                  onTap: () {
                    // Optional: Navigate to edit page when tapping the entire tile
                    _navigateToEditPage(context, post, token);
                  },
                ),
              );
            },
          ),
        );
      }

      return const SizedBox();
    },
  ),
        floatingActionButton: FloatingActionButton.small(
          child: const Icon(Icons.add),
          onPressed: () async {
            try {
              final authState = context.read<AuthBloc>().state;

              if (authState is! AuthSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must be logged in to add a post")));
                return;
              }

              UserModel currentUser;
              String authToken = authState.accessToken;

              if (authState.user != null) {
                // Case 1: User data is available in AuthBloc
                currentUser = authState.user as UserModel;
                print("✅ Using user from AuthBloc: ${currentUser.name}");
              } else {
                // Case 2: Browser refresh - try to restore user from storage
                print("🔄 Attempting to restore user from storage...");
                final userJson = await storage.getUser();

                if (userJson != null) {
                  try {
                    currentUser = UserModel.fromJson(userJson);
                    print("✅ User restored from storage: ${currentUser.name}");
                  } catch (e) {
                    print("❌ Failed to restore user from storage: $e");
                    // If restoration fails, we can't create posts
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Session expired. Please login again.")));
                    return;
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Session expired. Please login again.")));
                  return;
                }
              }

              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                builder: (context) => AddPostBottomSheet(currentUser: currentUser),
              );

              if (result != null) {
                final newPost = result['post'] as PostModel;
                final image = result['image'];

                context.read<PostBloc>().add(AddPostEvent(post: newPost, image: image, token: authToken));

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post added successfully")));
              }
            } catch (e) {
              print("❌ Error in FAB: $e");
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
            }
          },
        ),
      ),
    );
  }



  // heleper calss

  void _navigateToEditPage(BuildContext context, PostEntity post, String token) {
  // Navigate to edit post page
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => EditPostPage(
        postId: post.postId,
        token: token,
      ),
    ),
  );
}

void _showDeleteDialog(BuildContext context, int postId, String token) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Delete Post"),
        content: Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PostBloc>().add(DeletePost(postId: postId, token: token));
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}
}
