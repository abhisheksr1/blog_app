import 'dart:io';

import 'package:bolg_app/core/usecase/usecase.dart';
import 'package:bolg_app/features/blog/domain/entities/blog.dart';
import 'package:bolg_app/features/blog/domain/usecases/blog_upload.dart';
import 'package:bolg_app/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    on<BlogUploadEvent>(_onBlogUpload);
    on<GetAllBlogsEvent>(_onGetAllBlogs);
  }
  void _onBlogUpload(BlogUploadEvent event, Emitter<BlogState> emit) async {
    final res = await _uploadBlog(
      UploadBlogParams(
        posterId: event.posterId,
        title: event.title,
        content: event.content,
        topics: event.topics,
        image: event.image,
      ),
    );

    res.fold(
      (l) => emit(BlogFailure(l.message)),
      (r) => emit(BlogSuccess()),
    );
  }

  void _onGetAllBlogs(GetAllBlogsEvent event, Emitter<BlogState> emit) async{
    final res = await _getAllBlogs(NoParams());

    res.fold((l) => emit(BlogFailure(l.message)), (r) => emit(BlogDisplaySuccess(r)));
  }
}
