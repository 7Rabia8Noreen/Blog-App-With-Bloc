import 'package:blog_app_with_bloc/core/error/failure.dart';
import 'package:blog_app_with_bloc/core/use_case/use_case.dart';
import 'package:blog_app_with_bloc/core/common/entities/user.dart';
import 'package:blog_app_with_bloc/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserLogin implements UseCase<User, UserLoginParams> {
  final AuthRepository authRepository;
  UserLogin(
    this.authRepository,
  );
  @override
  Future<Either<Failure, User>> call(UserLoginParams params) async {
    return await authRepository.loginWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class UserLoginParams {
  final String email;
  final String password;

  UserLoginParams({
    required this.email,
    required this.password,
  });
}
