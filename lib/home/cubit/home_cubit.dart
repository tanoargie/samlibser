import 'package:logger/logger.dart';
import 'package:book_repository/models/book.dart';
import 'package:book_repository/book_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._bookRepository) : super(const HomeState());

  final BookRepository _bookRepository;
  final logger = Logger();

  void getBooks() async {
    try {
      final userBooks = await _bookRepository.getBooks();
      emit(state.copyWith(books: userBooks));
    } catch (e) {
      logger.e("Error getBooks", error: "$e");
    }
  }

  void addBook() async {
    try {
      final newBook = await _bookRepository.uploadBook();
      final savedBook = await _bookRepository.addBook(newBook);
      final savedBookMap = <String, Book>{savedBook.id: savedBook};
      final Map<String, Book> savedBooks = Map.of(state.books)
        ..addEntries(savedBookMap.entries);
      emit(state.copyWith(books: savedBooks));
    } catch (e) {
      logger.e("Error addBook", error: "$e");
    }
  }
}
