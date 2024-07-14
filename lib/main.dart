import 'package:blog_app_with_bloc/core/common/cubit/app_user/app_user_cubit.dart';
import 'package:blog_app_with_bloc/core/theme/theme.dart';
import 'package:blog_app_with_bloc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_app_with_bloc/features/auth/presentation/pages/login_page.dart';
import 'package:blog_app_with_bloc/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app_with_bloc/features/blog/presentation/pages/blogs_page.dart';
import 'package:blog_app_with_bloc/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencies();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => serviceLocator<AppUserCubit>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<AuthBloc>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<BlogBloc>(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkThemeMode,
      home: BlocSelector<AppUserCubit, AppUserState, bool>(
        selector: (state) {
          return state is AppUserLoggedIn;
        },
        builder: (context, isUserLoggedIn) {
          if (isUserLoggedIn) {
            return const BlogsPage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
