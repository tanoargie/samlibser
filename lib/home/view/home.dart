import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samlibser/app/bloc/app_bloc.dart';
import 'package:samlibser/home/cubit/home_cubit.dart';
import 'package:book_repository/book_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Page<void> page() {
    final bookRepository = BookRepository();
    return MaterialPage<void>(
        child: RepositoryProvider.value(
            value: bookRepository,
            child: BlocProvider<HomeCubit>(
                create: (_) => HomeCubit(bookRepository)..getBooks(),
                child: const HomePage())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: <Widget>[
            IconButton(
                key: const Key('homePage_logout_iconButton'),
                icon: const Icon(Icons.exit_to_app),
                onPressed: () =>
                    context.read<AppBloc>().add(const AppLogoutRequested()))
          ],
        ),
        body: Align(
          alignment: const Alignment(0, -1 / 3),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
              List<Text> listText = [];
              print(state);
              if (state.loading == false) {
                for (var book in state.books.entries) {
                  listText.add(Text(state.books[book.key]?.name ?? ''));
                }
                return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: listText.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: 50,
                        child: listText[index],
                      );
                    });
              }
              return const Center(child: CircularProgressIndicator());
            })
          ]),
        ),
        floatingActionButton:
            BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
          return FloatingActionButton(
              tooltip: 'Book upload',
              child: const Icon(Icons.add),
              onPressed: () => context.read<HomeCubit>().addBook());
        }));
  }
}
