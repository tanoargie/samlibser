import 'package:epub_view/epub_view.dart';
import 'package:logger/logger.dart';
import 'package:book_repository/book_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._bookRepository) : super(const HomeState());

  final BookRepository _bookRepository;
  final logger = Logger();

  Future<void> getBooksFromServer() async {
    emit(state.copyWith(loading: true, errorMessage: ""));
    try {
      final userBooks = await _bookRepository.getBooksFromServer();
      emit(state.copyWith(books: userBooks, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
      logger.e("Error getBooks", error: "$e");
    }
  }

  Future<void> getBooks() async {
    emit(state.copyWith(loading: true, errorMessage: ""));
    try {
      final userBooks = await _bookRepository.getBooks();
      emit(state.copyWith(books: userBooks, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
      logger.e("Error getBooks", error: "$e");
    }
  }

  Future<void> addBook() async {
    emit(state.copyWith(loading: true, errorMessage: ""));
    try {
      final newBook = await _bookRepository.uploadBook();
      final savedBook = await _bookRepository.addBook(newBook);
      final Map<String, EpubBook> savedBooks = Map.of(state.books ?? {})
        ..addAll(savedBook);
      emit(state.copyWith(books: savedBooks, loading: false));
    } on DuplicatedRecord {
      emit(state.copyWith(
          loading: false, errorMessage: DuplicatedRecord.message));
      logger.e("Error addBook", error: DuplicatedRecord.message);
    } on FileUploadCancelled {
      emit(state.copyWith(
          loading: false, errorMessage: FileUploadCancelled.message));
      logger.e("Error addBook", error: FileUploadCancelled.message);
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
      logger.e("Error addBook", error: "$e");
    }
  }

  Future<void> deleteBook(String key) async {
    emit(state.copyWith(loading: true, errorMessage: ""));
    try {
      final Map<String, EpubBook> savedBooks = Map.of(state.books ?? {});
      await _bookRepository.deleteBook(key);
      savedBooks.remove(key);
      emit(state.copyWith(books: savedBooks, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
      logger.e("Error addBook", error: "$e");
    }
  }
}
