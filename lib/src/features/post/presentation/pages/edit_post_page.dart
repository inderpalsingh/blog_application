import 'dart:typed_data';

import 'package:blog_application/src/features/post/domain/entities/post_entity.dart';
import 'package:blog_application/src/features/post/presentation/bloc/post_bloc.dart';
import 'package:blog_application/src/features/post/presentation/bloc/post_event.dart';
import 'package:blog_application/src/features/post/presentation/bloc/post_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  dynamic _selectedImage; // Can be XFile (mobile) or Uint8List (web)
  String _fileName = '';
  PostEntity? _currentPost;
  bool _removeCurrentImage = false;

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
          _selectedImage = pickedFile;
          _fileName = pickedFile.name;
          _removeCurrentImage = false; // User selected new image, don't remove
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _removeCurrentImage = true;
    });
  }

  void _editImage() {
    // Show bottom sheet with image options
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Image', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _removeImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updatePost() async {
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

      // Convert XFile to bytes if needed (for web compatibility)
      dynamic imageToSend = _selectedImage;

      // If you need to convert XFile to bytes for web
      if (_selectedImage is XFile) {
        try {
          final bytes = await (_selectedImage as XFile).readAsBytes();
          imageToSend = bytes;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to process image: $e')),
          );
          return;
        }
      }

      // ✅ FIX: Don't print full token to avoid overflow
      print("🔄 UPDATE POST URL = http://192.168.1.200:10000/api/posts/${widget.postId}");
      print("UPDATE POST DATA: title=${_titleController.text}, content=${_contentController.text}");
      print("POST ID: ${widget.postId}");
      print("TOKEN PREVIEW: ${widget.token.substring(0, 20)}...");

      context.read<PostBloc>().add(UpdatePostEvent(
        postId: widget.postId,
        post: updatedPost,
        image: imageToSend, // Pass the selected image
        token: widget.token,
      ));

      // Show loading state
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updating post...')),
      );
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
          // ✅ SINGLE SAVE BUTTON - Removed duplicate button from bottom
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updatePost,
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: BlocConsumer<PostBloc, PostState>(
        listener: (context, state) {
          if (state is PostUpdated) {
            // ✅ SUCCESS: Show message and navigate to posts page using go_router
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Post updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop(); // Use go_router to navigate to posts page
          } else if (state is PostError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return _currentPost == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
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
                        const SizedBox(height: 24),

                        // Image Section
                        const Text(
                          'Post Image',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Current Image Preview with Edit Button
                        if (_currentPost!.imageUrl != null && _currentPost!.imageUrl!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Current Image:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  // Edit Image Button - Only show if not already marked for removal
                                  if (!_removeCurrentImage)
                                    ElevatedButton.icon(
                                      onPressed: _editImage,
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: const Text('Edit Image'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Stack(
                                children: [
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
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.error, color: Colors.red, size: 40),
                                                SizedBox(height: 8),
                                                Text('Failed to load image'),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  if (_removeCurrentImage)
                                    Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.delete, color: Colors.white, size: 40),
                                            SizedBox(height: 8),
                                            Text(
                                              'Image will be removed',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  // Edit Icon Overlay
                                  if (!_removeCurrentImage)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                          onPressed: _editImage,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (!_removeCurrentImage)
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _removeImage,
                                      icon: const Icon(Icons.delete),
                                      label: const Text('Remove Image'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      onPressed: _editImage,
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Change Image'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.blue,
                                        side: const BorderSide(color: Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 16),
                            ],
                          ),

                        // Show this message if there's no current image
                        if ((_currentPost!.imageUrl == null || _currentPost!.imageUrl!.isEmpty) && _selectedImage == null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('No image attached to this post', style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 16),
                            ],
                          ),

                        // New Image Preview
                        if (_selectedImage != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('New Image Preview:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              const SizedBox(height: 8),
                              Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green, width: 2),
                                ),
                                child: _selectedImage is XFile
                                    ? FutureBuilder<Widget>(
                                        future: _getImagePreview(_selectedImage as XFile),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.done) {
                                            return snapshot.data ?? const Icon(Icons.error);
                                          }
                                          return const Center(child: CircularProgressIndicator());
                                        },
                                      )
                                    : Image.memory(
                                        _selectedImage as Uint8List,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => setState(() {
                                      _selectedImage = null;
                                      _removeCurrentImage = false;
                                    }),
                                    icon: const Icon(Icons.cancel),
                                    label: const Text('Cancel New Image'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.orange,
                                      side: const BorderSide(color: Colors.orange),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _fileName,
                                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),

                        // Image Picker Buttons (only show if no current image being edited)
                        if ((_currentPost!.imageUrl == null || _currentPost!.imageUrl!.isEmpty) && _selectedImage == null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Add an image to your post:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _pickImage(ImageSource.gallery),
                                      icon: const Icon(Icons.photo_library),
                                      label: const Text('Choose from Gallery'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _pickImage(ImageSource.camera),
                                      icon: const Icon(Icons.camera_alt),
                                      label: const Text('Take a Photo'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),


                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }

  Future<Widget> _getImagePreview(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (e) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 40),
            SizedBox(height: 8),
            Text('Failed to load image'),
          ],
        ),
      );
    }
  }
}