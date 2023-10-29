import 'package:authentication_repository/authentication_repository.dart';
import 'package:book_repository/book_repository.dart';
import 'package:flutter/material.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samlibser/app/bloc/app_bloc.dart';
import 'package:samlibser/theme.dart';
import 'package:samlibser/app/routes/routes.dart';

class App extends StatelessWidget {
  const App({
    required AuthenticationRepository authenticationRepository,
    required BookRepository bookRepository,
    super.key,
  })  : _authenticationRepository = authenticationRepository,
        _bookRepository = bookRepository;

  final AuthenticationRepository _authenticationRepository;
  final BookRepository _bookRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthenticationRepository>(
              create: (context) => _authenticationRepository),
          RepositoryProvider<BookRepository>(
              create: (context) => _bookRepository)
        ],
        child: BlocProvider(
          create: (_) => AppBloc(
            authenticationRepository: _authenticationRepository,
          ),
          child: const AppView(),
        ));
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: FlowBuilder<AppState>(
        state: context.select((AppBloc bloc) => bloc.state),
        onGeneratePages: onGenerateAppViewPages,
      ),
    );
  }
}
