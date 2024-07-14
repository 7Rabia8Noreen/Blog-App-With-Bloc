import 'dart:io';

import 'package:blog_app_with_bloc/core/use_case/use_case.dart';
import 'package:blog_app_with_bloc/features/blog/domain/use_cases/get_all_blogs.dart';
import 'package:blog_app_with_bloc/features/blog/domain/use_cases/upload_blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/blog.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog _uploadBlog;
  final GetAllBlogs _getAllBlogs;

  BlogBloc({
    required UploadBlog uploadBlog,
    required GetAllBlogs getAllBlogs,
  })  : _uploadBlog = uploadBlog,
        _getAllBlogs = getAllBlogs,
        super(BlogInitial()) {
    on<BlogEvent>((event, emit) => emit(BlogLoading()));
    on<BlogUpload>(_onBlogUpload);
    on<BlogFetchAllBlogs>(_onFetchAllBlogs);
  }

  void _onBlogUpload(BlogUpload event, Emitter<BlogState> state) async {
    final res = await _uploadBlog(UploadBlogParams(
      image: event.image,
      title: event.title,
      content: event.content,
      posterId: event.posterId,
      topics: event.topics,
    ));
    res.fold(
      // ignore: invalid_use_of_visible_for_testing_member
      (l) => emit(BlogFailure(l.message)),
      // ignore: invalid_use_of_visible_for_testing_member
      (r) => emit(
        BlogUploadSuccess(),
      ),
    );
  }

  void _onFetchAllBlogs(
    BlogFetchAllBlogs event,
    Emitter<BlogState> state,
  ) async {
    final res = await _getAllBlogs(NoParams());
    res.fold(
      // ignore: invalid_use_of_visible_for_testing_member
      (l) => emit(
        BlogFailure(
          l.message,
        ),
      ),
      // ignore: invalid_use_of_visible_for_testing_member
      (r) => emit(
        BlogsDisplaySuccess(r),
      ),
    );
  }
}
