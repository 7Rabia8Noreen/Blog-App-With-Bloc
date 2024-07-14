import 'dart:io';

import 'package:blog_app_with_bloc/core/common/cubit/app_user/app_user_cubit.dart';
import 'package:blog_app_with_bloc/core/common/widgets/loader.dart';
import 'package:blog_app_with_bloc/core/theme/app_pallete.dart';
import 'package:blog_app_with_bloc/core/utils/pick_image.dart';
import 'package:blog_app_with_bloc/core/utils/show_snackbar.dart';
import 'package:blog_app_with_bloc/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app_with_bloc/features/blog/presentation/pages/blogs_page.dart';
import 'package:blog_app_with_bloc/features/blog/presentation/widgets/blog_editor.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class AddBlogPage extends StatefulWidget {
  const AddBlogPage({super.key});

  static route() => MaterialPageRoute(
        builder: (context) => const AddBlogPage(),
      );

  @override
  State<AddBlogPage> createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  final _titleController = TextEditingController();

  final _contentController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final List<String> _selectedTopics = [];
  File? image;

  void _selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _contentController.dispose();
  }

  void _uploadBlog() {
    if (formKey.currentState!.validate() &&
        _selectedTopics.isNotEmpty &&
        image != null) {
      final posterId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;

      context.read<BlogBloc>().add(
            BlogUpload(
              image: image!,
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              posterId: posterId,
              topics: _selectedTopics,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Blog'),
        actions: [
          CupertinoButton(
            child: const Icon(
              Icons.done_rounded,
            ),
            onPressed: () {
              _uploadBlog();
            },
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackbar(context, state.error);
          }
          if (state is BlogUploadSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              BlogsPage.route(),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Loader();
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    image != null
                        ? GestureDetector(
                            onTap: _selectImage,
                            child: SizedBox(
                              height: 150,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(
                                    image?.path ?? '',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              _selectImage();
                            },
                            child: DottedBorder(
                              color: AppPallete.borderColor,
                              radius: const Radius.circular(10),
                              dashPattern: const [10, 4],
                              borderType: BorderType.RRect,
                              borderPadding: const EdgeInsets.all(10),
                              strokeCap: StrokeCap.round,
                              child: const SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.folder_open),
                                    Text(
                                      'Select your image',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 20,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'Technology',
                          'Business',
                          'Programming',
                          'Entertainment',
                        ]
                            .map((e) => Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_selectedTopics.contains(e)) {
                                        _selectedTopics.remove(e);
                                      } else {
                                        _selectedTopics.add(e);
                                      }
                                      setState(() {});
                                    },
                                    child: Chip(
                                      label: Text(e),
                                      color: _selectedTopics.contains(e)
                                          ? const MaterialStatePropertyAll(
                                              AppPallete.gradient1,
                                            )
                                          : null,
                                      side: _selectedTopics.contains(e)
                                          ? null
                                          : const BorderSide(
                                              color: AppPallete.borderColor,
                                            ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    BlogEditor(
                      controller: _titleController,
                      hintText: 'Blog Title',
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    BlogEditor(
                      controller: _contentController,
                      hintText: 'Blog Content',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
