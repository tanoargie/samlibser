part of 'home_cubit.dart';

final class HomeState extends Equatable {
  const HomeState({this.books = const <String, Book>{}, this.loading = false});

  final Map<String, Book> books;
  final bool loading;

  @override
  List<Object?> get props => [books, loading];

  HomeState copyWith({Map<String, Book>? books, required bool loading}) {
    return HomeState(books: books ?? this.books, loading: loading);
  }
}
