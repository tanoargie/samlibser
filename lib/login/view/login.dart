import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samlibser/login/view/login_form.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:samlibser/login/cubit/login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static Page<void> page() => const MaterialPage<void>(child: LoginPage());

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: BlocProvider(
                create: (_) =>
                    LoginCubit(context.read<AuthenticationRepository>()),
                child: const LoginForm(),
              )),
          Center(
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'When logged/signed up you accept our ',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: 'terms',
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(
                            'https://samlibser.samser.co/terms/terms.pdf'));
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
