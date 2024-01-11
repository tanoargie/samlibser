import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:book_repository/book_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:samlibser/app/view/app.dart';
import 'package:samlibser/app/bloc/app_bloc.dart';
import 'package:samlibser/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.user.first;

  final bookRepository =
      BookRepository(authenticationRepository: authenticationRepository);
  await SentryFlutter.init((options) {
    options.dsn = const String.fromEnvironment('SENTRY_DSN');
    options.tracesSampleRate = 1.0;
  }, appRunner: () {
    runApp(App(
        authenticationRepository: authenticationRepository,
        bookRepository: bookRepository));
  });
}
