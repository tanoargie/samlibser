part of 'home_cubit.dart';

final class HomeState extends Equatable {
  const HomeState(
      {this.books = const <String, Book>{},
      this.loading = false,
      this.errorMessage = ""});

  final Map<String, Book> books;
  final bool loading;
  final String? errorMessage;

  @override
  List<Object?> get props => [books, loading, errorMessage];

  HomeState copyWith(
      {Map<String, Book>? books, required bool loading, String? errorMessage}) {
    return HomeState(
        books: books ?? this.books,
        loading: loading,
        errorMessage: errorMessage);
  }
}
