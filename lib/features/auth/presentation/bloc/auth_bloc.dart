import 'package:blog_app_with_bloc/core/common/cubit/app_user/app_user_cubit.dart';
import 'package:blog_app_with_bloc/core/use_case/use_case.dart';
import 'package:blog_app_with_bloc/core/common/entities/user.dart';
import 'package:blog_app_with_bloc/features/auth/domain/use_cases/current_user.dart';
import 'package:blog_app_with_bloc/features/auth/domain/use_cases/user_login.dart';
import 'package:blog_app_with_bloc/features/auth/domain/use_cases/user_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignup _userSignup;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;
  AuthBloc({
    required UserSignup userSignup,
    required UserLogin userLogin,
    required CurrentUser currrentUser,
    required AppUserCubit appUserCubit,
  })  : _userSignup = userSignup,
        _userLogin = userLogin,
        _currentUser = currrentUser,
        _appUserCubit = appUserCubit,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignup>(_onAuthSignup);
    on<AuthLogin>(_onAuthLogin);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
  }

  void _isUserLoggedIn(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _currentUser(NoParams());
    res.fold((failure) {
      print('failure message ${failure.message}');
      emit(
        AuthFailure(failure.message),
      );
    }, (user) {
      print('test user  ${user.id}');
      _emitAuthSuccess(user, emit);
    });
  }

  void _onAuthSignup(
    AuthSignup event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('signing up user');
    final res = await _userSignup(UserSignupParams(
      name: event.name,
      email: event.email,
      password: event.password,
    ));
    debugPrint('signed up is success check  ${res.isRight()}');
    debugPrint('Final result   ${res.toString()}');
    res.fold(
      (failure) => emit(
        AuthFailure(failure.message),
      ),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthLogin(
    AuthLogin event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('signing in user');
    final res = await _userLogin(UserLoginParams(
      email: event.email,
      password: event.password,
    ));
    debugPrint('signed in is success check  ${res.isRight()}');
    debugPrint('Final result   ${res.toString()}');
    res.fold(
      (failure) => emit(
        AuthFailure(failure.message),
      ),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _emitAuthSuccess(
    User user,
    Emitter<AuthState> emit,
  ) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }
}
