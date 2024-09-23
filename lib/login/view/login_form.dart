import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samlibser/login/cubit/login_cubit.dart';
import 'package:formz/formz.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Authentication Failure'),
              ),
            );
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 120,
              ),
              const SizedBox(height: 8),
              SizedBox(
                  width: 220.0,
                  child: Column(children: [
                    _GoogleLoginButton(),
                    const SizedBox(height: 4),
                    if (defaultTargetPlatform == TargetPlatform.iOS)
                      const SizedBox(height: 4),
                  ]))
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      textColor: Colors.black,
      color: Colors.white,
      child: const Row(children: <Widget>[
        Image(image: AssetImage('assets/google_light.png')),
        Text('Sign in with Google')
      ]),
      onPressed: () => context.read<LoginCubit>().logInWithGoogle(),
    );
  }
}
