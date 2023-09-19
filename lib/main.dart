import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:samlibser/app/view/app.dart';

Future<void> main() async {
  final authenticationRepository = AuthenticationRepository();
  WidgetsFlutterBinding.ensureInitialized();
  await authenticationRepository.user;
  runApp(App(authenticationRepository: authenticationRepository));
}
