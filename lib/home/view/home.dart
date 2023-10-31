import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              return HomeCubit(context.read<BookRepository>())..getBooks();
            },
            child: const HomePage()));
  }

  List<TrackSize> getColumnSizes(Size screenSize) {
    if (screenSize.width > 768) {
      return [1.fr, 1.fr, 1.fr, 1.fr];
    } else if (screenSize.width > 480) {
      return [1.fr, 1.fr];
    } else {
      return [1.fr];
    }
  }

  List<BookCard> getEntries(
      Map<String, EpubBook> mapOfEpubs, BuildContext context) {
    List<BookCard> listOfWidgets = [];
    for (var i = 0; i < mapOfEpubs.entries.length; i++) {
      listOfWidgets.add(BookCard(
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
              onPressed: () => context.read<HomeCubit>().getBooksFromServer()),
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
                Map<String, EpubBook> mapOfEpubs = state.books ?? {};
                if (mapOfEpubs.isEmpty) {
                  return const Center(child: Text('No books!'));
                }
                if (state.errorMessage.isNotEmpty) {
                  return const Center(
                      child: Text("There was an error getting book links"));
                }
                final List<BookCard> entries = getEntries(mapOfEpubs, context);
                final List<TrackSize> columnSizes =
                    getColumnSizes(MediaQuery.sizeOf(context));
                final rowSizes = List.generate(
                    entries.length ~/ columnSizes.length, (_) => auto);
                return CustomScrollView(slivers: [
                  SliverToBoxAdapter(
                      child: LayoutGrid(
                    columnSizes: columnSizes,
                    rowSizes: rowSizes,
                    rowGap: 40,
                    columnGap: 24,
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
