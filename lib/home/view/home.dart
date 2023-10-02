import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samlibser/app/bloc/app_bloc.dart';
import 'package:samlibser/home/cubit/home_cubit.dart';
import 'package:book_repository/book_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key
  });

  static Page<void> page() {
    final bookRepository = BookRepository();
    return MaterialPage<void>(
      child: RepositoryProvider.value(
        value: bookRepository,
        child: BlocProvider<HomeCubit>(
          create: (_) => HomeCubit(
            bookRepository
          ),
          child: const HomePage()
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = context.select((AppBloc bloc) => bloc.state.user);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: <Widget>[
            IconButton(
              key: const Key('homePage_logout_iconButton'),
              icon: const Icon(Icons.exit_to_app),
              onPressed: () => context.read<AppBloc>().add(const AppLogoutRequested())
            )
          ],
        ),
        body: Align(
          alignment: const Alignment(0, -1 / 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 4),
              Text(user.email ?? '', style: textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(user.name ?? '', style: textTheme.headlineSmall),
            ],
          ),
        ),
        floatingActionButton: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return FloatingActionButton(
             tooltip: 'Book upload',
             child: const Icon(Icons.add),
             onPressed: () => context.read<HomeCubit>().addBook()
            );
          }
        )
      );
  }
}

