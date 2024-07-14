import 'package:blog_app_with_bloc/core/common/widgets/loader.dart';
import 'package:blog_app_with_bloc/core/theme/app_pallete.dart';
import 'package:blog_app_with_bloc/core/utils/show_snackbar.dart';
import 'package:blog_app_with_bloc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_app_with_bloc/features/auth/presentation/pages/login_page.dart';
import 'package:blog_app_with_bloc/features/auth/presentation/widgets/app_field.dart';
import 'package:blog_app_with_bloc/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  static route() => MaterialPageRoute(
        builder: (context) => const SignupPage(),
      );

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showSnackbar(context, state.message);
            }
            if (state is AuthSuccess) {
              Navigator.push(context, LoginPage.route());
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Loader();
            }
            return Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  AppField(
                    hintText: 'Name',
                    controller: _nameController,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  AppField(
                    hintText: 'Email',
                    controller: _emailController,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  AppField(
                    hintText: 'Password',
                    controller: _passwordController,
                    isObscureText: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  AuthGradientButton(
                    title: 'Sign Up',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        debugPrint('validating signup form');
                        context.read<AuthBloc>().add(
                              AuthSignup(
                                email: _emailController.text.trim(),
                                name: _nameController.text.trim(),
                                password: _passwordController.text.trim(),
                              ),
                            );
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        LoginPage.route(),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                          text: 'Already have an account? ',
                          style: Theme.of(context).textTheme.titleMedium,
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppPallete.gradient2,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          ]),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
