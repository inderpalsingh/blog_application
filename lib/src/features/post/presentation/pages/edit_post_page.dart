import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';
import 'package:blog_application/src/features/post/presentation/bloc/post_bloc.dart';
import 'package:blog_application/src/features/post/presentation/bloc/post_event.dart';
import 'package:blog_application/src/features/post/presentation/bloc/post_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class EditPostPage extends StatefulWidget {
  final int postId;
  final String token;

  const EditPostPage({
    Key? key,
    required this.postId,
    required this.token,
  }) : super(key: key);

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<int>? _imageBytes;
  String _fileName = '';
  PostEntity? _currentPost;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _fileName = 'update_image.png';

    // Load the post data
    _loadPost();
  }

  void _loadPost() {
    // You might need to load the post from your bloc or directly from API
    // For now, we'll get it from the posts list in the bloc state
    final postBloc = context.read<PostBloc>();
    final state = postBloc.state;

    if (state is PostsLoaded) {
      final post = state.posts.firstWhere(
        (p) => p.postId == widget.postId,
        orElse: () => throw Exception('Post not found'),
      );
      setState(() {
        _currentPost = post;
        _titleController.text = post.title;
        _contentController.text = post.content;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _fileName = pickedFile.name;
        });
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _updatePost() {
    if (_formKey.currentState!.validate() && _currentPost != null) {
      final updatedPost = PostEntity(
        postId: _currentPost!.postId,
        title: _titleController.text,
        content: _contentController.text,
        imageUrl: _currentPost!.imageUrl, // Preserve existing URL
        createAt: _currentPost!.createAt,
        updateAt: DateTime.now(),
        category: _currentPost!.category,
        user: _currentPost!.user,
        comments: _currentPost!.comments,
      );

      context.read<PostBloc>().add(UpdatePostEvent(
        postId: widget.postId,
        post: updatedPost,
        imageBytes: _imageBytes,
        fileName: _fileName,
        image: null,
        token: '',
      ));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updatePost,
          ),
        ],
      ),
      body: BlocListener<PostBloc, PostState>(
        listener: (context, state) {
          if (state is PostUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post updated successfully')),
            );
            Navigator.of(context).pop();
          } else if (state is PostError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: _currentPost == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // ... (same form fields as before)
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Content',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter content';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Current Image Preview
                      if (_currentPost!.imageUrl != null && _currentPost!.imageUrl!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Current Image:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _currentPost!.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.error, color: Colors.red),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // New Image Preview and picker buttons...
                      // ... (same as previous implementation)
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}