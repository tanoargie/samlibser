import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samlibser/reset_password/cubit/reset_password_cubit.dart';
import 'package:samlibser/reset_password/view/reset_password_form.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const ResetPasswordPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocProvider<ResetPasswordCubit>(
          create: (_) =>
              ResetPasswordCubit(context.read<AuthenticationRepository>()),
          child: const ResetPasswordForm(),
        ),
      ),
    );
  }
}
