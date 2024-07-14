import 'package:blog_app_with_bloc/core/common/cubit/app_user/app_user_cubit.dart';
import 'package:blog_app_with_bloc/core/secrets/app_secrets.dart';
import 'package:blog_app_with_bloc/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:blog_app_with_bloc/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blog_app_with_bloc/features/auth/domain/repository/auth_repository.dart';
import 'package:blog_app_with_bloc/features/auth/domain/use_cases/current_user.dart';
import 'package:blog_app_with_bloc/features/auth/domain/use_cases/user_login.dart';
import 'package:blog_app_with_bloc/features/auth/domain/use_cases/user_sign_up.dart';
import 'package:blog_app_with_bloc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_app_with_bloc/features/blog/data/data_sources/blog_remote_data_source.dart';
import 'package:blog_app_with_bloc/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:blog_app_with_bloc/features/blog/domain/repositories/blog_repository.dart';
import 'package:blog_app_with_bloc/features/blog/domain/use_cases/get_all_blogs.dart';
import 'package:blog_app_with_bloc/features/blog/domain/use_cases/upload_blog.dart';
import 'package:blog_app_with_bloc/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBlog();
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  serviceLocator.registerLazySingleton(() => supabase.client);

  //Core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
}

void _initAuth() {
  //DataSource
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        supabaseClient: serviceLocator(),
      ),
    )
    //Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: serviceLocator(),
      ),
    )
    //UseCases
    ..registerFactory(
      () => UserSignup(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserLogin(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CurrentUser(
        serviceLocator(),
      ),
    )
    //Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignup: serviceLocator(),
        userLogin: serviceLocator(),
        currrentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}

void _initBlog() {
  //Date source
  serviceLocator
    ..registerFactory<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    //Repository
    ..registerFactory<BlogRepository>(
      () => BlogRepositoryImpl(
        serviceLocator(),
      ),
    )
    //Use case
    ..registerFactory(
      () => UploadBlog(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetAllBlogs(
        serviceLocator(),
      ),
    )
    //Bloc
    ..registerLazySingleton(
      () => BlogBloc(
        uploadBlog: serviceLocator(),
        getAllBlogs: serviceLocator(),
      ),
    );
}
