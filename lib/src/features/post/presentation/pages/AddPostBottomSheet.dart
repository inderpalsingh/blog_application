import 'dart:typed_data';
import 'package:blog_application/src/features/auth/domain/entities/user_entity.dart';
import 'package:blog_application/src/features/post/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/post_model.dart';
import '../../data/models/category_model.dart';

class AddPostBottomSheet extends StatefulWidget {
  final UserEntity currentUser;
  final CategoryModel? selectedCategory;

  const AddPostBottomSheet({
    super.key,
    required this.currentUser,
    this.selectedCategory,
  });

  @override
  State<AddPostBottomSheet> createState() => _AddPostBottomSheetState();
}

class _AddPostBottomSheetState extends State<AddPostBottomSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  XFile? _pickedImage;
  Uint8List? _webImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();

    if (kIsWeb) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _webImage = await pickedFile.readAsBytes();
      }
    } else {
      _pickedImage = await picker.pickImage(source: ImageSource.gallery);
    }
    setState(() {});
  }

  void _submit() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;

    final category = widget.selectedCategory ?? CategoryModel(categoryId: 2, categoryName: 'Default', categoryDescription: 'Default category');

    // Map UserEntity → UserModel
    final user = UserModel(
      id: widget.currentUser.id,
      name: widget.currentUser.name,
      email: widget.currentUser.email,
      password: "", // password not needed for posting
      age: widget.currentUser.age,
      gender: widget.currentUser.gender,
    );

    final newPost = PostModel(
      postId: 0,
      title: _titleController.text,
      content: _contentController.text,
      imageUrl: null,
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
      category: category,
      user: user,
      comments: [],
    );

    Navigator.of(context).pop({
      'post': newPost,
      'image': kIsWeb ? _webImage : _pickedImage,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Pick Image'),
                ),
                const SizedBox(width: 8),
                _pickedImage != null || _webImage != null
                    ? const Text('Image selected')
                    : const Text('No image'),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Add Post'),
            ),
          ],
        ),
      ),
    );
  }
}
