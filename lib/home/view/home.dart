import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:epubx/epubx.dart';
import 'package:samlibser/app/bloc/app_bloc.dart';
import 'package:samlibser/home/cubit/home_cubit.dart';
import 'package:book_repository/book_repository.dart';
import 'package:samlibser/widgets/book_card.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Page<void> page() {
    return MaterialPage<void>(
        child: BlocProvider<HomeCubit>(
            create: (context) {
              return HomeCubit(context.read<BookRepository>())
                ..getBooks()
                ..getBooksPositions();
            },
            child: const HomePage()));
  }

  int numberOfColumnsByScreen(Size screenSize) {
    if (screenSize.width > 1024) {
      return 4;
    } else if (screenSize.width > 480) {
      return 2;
    } else {
      return 1;
    }
  }

  List<BookCard> getEntries(Map<String, EpubBook> mapOfEpubs,
      Map<String, String> mapOfPositions, BuildContext context) {
    List<BookCard> listOfWidgets = [];
    for (var i = 0; i < mapOfEpubs.entries.length; i++) {
      listOfWidgets.add(BookCard(
          updatePositionCallback: (String cfi) {
            context
                .read<HomeCubit>()
                .updateBookPosition(mapOfEpubs.entries.elementAt(i).key, cfi);
          },
          cfi: mapOfPositions[mapOfEpubs.entries.elementAt(i).key],
          deleteCallback: () {
            context
                .read<HomeCubit>()
                .deleteBook(mapOfEpubs.entries.elementAt(i).key);
          },
          epubBook: mapOfEpubs.entries.elementAt(i).value));
    }
    return listOfWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            key: const Key('homePage_refresh_iconButton'),
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HomeCubit>().getBooksFromServer();
              context.read<HomeCubit>().getBooksPositionsFromServer();
            },
          ),
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
          child: Container(
            alignment: Alignment.topCenter,
            child: BlocListener<HomeCubit, HomeState>(listener:
                (context, state) {
              if (state.errorMessage.toString() != "") {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage.toString())));
              }
            }, child:
                BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
              if (state.loading == false) {
                Map<String, EpubBook> mapOfEpubs = state.books;
                Map<String, String> mapOfPositions = state.positions;
                if (mapOfEpubs.isEmpty) {
                  return const Center(child: Text('No books!'));
                }
                if (state.errorMessage.isNotEmpty) {
                  return const Center(
                      child: Text("There was an error getting book links"));
                }
                final List<BookCard> entries =
                    getEntries(mapOfEpubs, mapOfPositions, context);
                final int numberOfColumns = min(entries.length,
                    numberOfColumnsByScreen(MediaQuery.sizeOf(context)));
                final List<TrackSize> columnSizes =
                    List.generate(numberOfColumns, (_) => 1.fr);
                final List<TrackSize> rowSizes = List.generate(
                    entries.length ~/ columnSizes.length, (_) => auto);
                return CustomScrollView(slivers: [
                  SliverToBoxAdapter(
                      child: LayoutGrid(
                    columnSizes: columnSizes,
                    rowSizes: rowSizes,
                    rowGap: 12,
                    columnGap: 12,
                    children: entries,
                  ))
                ]);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            })),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
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
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => context.read<HomeCubit>().addBook());
        }));
  }
}
