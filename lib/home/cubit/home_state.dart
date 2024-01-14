part of 'home_cubit.dart';

final class HomeState extends Equatable {
  const HomeState(
      {this.books = const <String, EpubBook>{},
      this.loading = false,
      this.errorMessage = "",
      this.positions = const <String, String>{}});

  // map id -> epubBook
  final Map<String, EpubBook> books;
  // map id -> last position
  final Map<String, String> positions;
  final bool loading;
  final String errorMessage;

  @override
  List<Object?> get props => [books, loading, errorMessage, positions];

  HomeState copyWith({
    Map<String, EpubBook>? books,
    Map<String, String>? positions,
    required bool loading,
    String? errorMessage,
  }) {
    Map<String, String> newPositions = Map.from(this.positions)
      ..addAll(positions ?? {});
    return HomeState(
        books: books ?? this.books,
        loading: loading,
        errorMessage: errorMessage ?? this.errorMessage,
        positions: newPositions);
  }
}
