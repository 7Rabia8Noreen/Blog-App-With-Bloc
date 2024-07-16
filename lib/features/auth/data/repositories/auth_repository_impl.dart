import 'package:blog_app_with_bloc/core/error/failure.dart';
import 'package:blog_app_with_bloc/core/error/server_exeptions.dart';
import 'package:blog_app_with_bloc/core/network/internet_checker.dart';
import 'package:blog_app_with_bloc/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:blog_app_with_bloc/core/common/entities/user.dart';
import 'package:blog_app_with_bloc/features/auth/data/models/user_model.dart';
import 'package:blog_app_with_bloc/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final InternetChecker internetChecker;
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.internetChecker,
  });

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!await (internetChecker.isConnected)) {
        final session = remoteDataSource.currentUserSession;
        if (session == null) {
          return left(Failure('User not logged in!'));
        }
        return right(
          UserModel(
            id: session.user.id,
            name: '',
            email: session.user.email ?? '',
          ),
        );
      }

      final user = await remoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failure('User not logged in!'));
      }
      print('user logged in');
      return right(user);
    } on ServerException catch (e) {
      print('failing message ${e.message}');
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(() async => await remoteDataSource.loginWithEmailPassword(
          email: email,
          password: password,
        ));
  }

  @override
  Future<Either<Failure, User>> signupWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return _getUser(() async => await remoteDataSource.signupWithEmailPassword(
          name: name,
          email: email,
          password: password,
        ));
  }

  Future<Either<Failure, User>> _getUser(
    Future<User> Function() fn,
  ) async {
    try {
      if (!await (internetChecker.isConnected)) {
        return Left(Failure('No internet connection'));
      }
      final user = await fn();
      return right(user);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
