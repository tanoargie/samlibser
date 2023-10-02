part of 'home_cubit.dart';

final class HomeState extends Equatable {
  const HomeState({
    this.books = const <String, Book>{},
  });

  final Map<String, Book> books;

  @override
  List<Object?> get props => [books];

  HomeState copyWith({
    required Map<String, Book> books,
  }) {
    return HomeState(
      books: this.books,
    );
  }
}
