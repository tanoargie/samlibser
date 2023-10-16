part of 'home_cubit.dart';

final class HomeState extends Equatable {
  const HomeState(
      {this.books = const <String, String>{},
      this.loading = false,
      this.errorMessage = ""});

  // map id -> signedURL
  final Map<String, String> books;
  final bool loading;
  final String errorMessage;

  @override
  List<Object?> get props => [books, loading, errorMessage];

  HomeState copyWith(
      {Map<String, String>? books,
      required bool loading,
      String? errorMessage}) {
    return HomeState(
        books: books ?? this.books,
        loading: loading,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}
