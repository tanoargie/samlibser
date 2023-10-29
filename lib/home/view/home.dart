import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samlibser/app/bloc/app_bloc.dart';
import 'package:samlibser/home/cubit/home_cubit.dart';
import 'package:book_repository/book_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:samlibser/widgets/book_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Page<void> page() {
    return MaterialPage<void>(
        child: BlocProvider<HomeCubit>(
            create: (context) {
              return HomeCubit(BookRepository(
                  authenticationRepository:
                      context.read<AuthenticationRepository>()))
                ..getBooks();
            },
            child: const HomePage()));
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
            BlocListener<HomeCubit, HomeState>(listener: (context, state) {
              if (state.errorMessage.toString() != "") {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage.toString())));
              }
            }, child:
                BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
              List<EpubBook> listEpubs = state.books.values.toList();
              print(state.loading);
              print(listEpubs.length);
              if (state.loading == false) {
                if (listEpubs.isEmpty) {
                  return const Text('No books!');
                }
                if (state.errorMessage.isNotEmpty) {
                  return const Text("There was an error getting book links");
                }
                return Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: listEpubs.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return BookCard(
                            epubBook: listEpubs[index],
                          );
                        }));
              } else {
                if (listEpubs.isNotEmpty) {
                  return Expanded(
                      child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: listEpubs.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return BookCard(
                              epubBook: listEpubs[index],
                            );
                          }));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }
            })),
          ]),
        ),
        bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books),
                label: 'Library',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Account',
              ),
            ],
            currentIndex: context.read<AppBloc>().state.selectedMenuIndex,
            selectedItemColor: Colors.amber[800],
            onTap: (int newIndex) =>
                context.read<AppBloc>().add(AppSelectedIndex(newIndex))),
        floatingActionButton:
            BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
          return FloatingActionButton(
              tooltip: 'Book upload',
              child: const Icon(Icons.add),
              onPressed: () => context.read<HomeCubit>().addBook());
        }));
  }
}
