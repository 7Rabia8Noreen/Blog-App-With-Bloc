import 'package:blog_app_with_bloc/core/common/widgets/loader.dart';
import 'package:blog_app_with_bloc/core/theme/app_pallete.dart';
import 'package:blog_app_with_bloc/core/utils/show_snackbar.dart';
import 'package:blog_app_with_bloc/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app_with_bloc/features/blog/presentation/pages/add_blog.dart';
import 'package:blog_app_with_bloc/features/blog/presentation/widgets/blog_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogsPage extends StatefulWidget {
  const BlogsPage({super.key});

  static route() => MaterialPageRoute(
        builder: (context) => const BlogsPage(),
      );

  @override
  State<BlogsPage> createState() => _BlogsPageState();
}

class _BlogsPageState extends State<BlogsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BlogBloc>().add(BlogFetchAllBlogs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
        automaticallyImplyLeading: false,
        actions: [
          CupertinoButton(
            child: const Icon(
              Icons.add_circle_outlined,
            ),
            onPressed: () {
              Navigator.push(
                context,
                AddBlogPage.route(),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackbar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Loader();
          }
          if (state is BlogsDisplaySuccess) {
            return ListView.builder(
              itemCount: state.blogs.length,
              itemBuilder: (context, index) {
                final blog = state.blogs[index];
                return BlogCard(
                  blog: blog,
                  color: index % 3 == 0
                      ? AppPallete.gradient1
                      : index % 3 == 1
                          ? AppPallete.gradient2
                          : AppPallete.gradient3,
                );
              },
            );
          }
          return const Center(
              child: Text(
            'No Blogs Found',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ));
        },
      ),
    );
  }
}
