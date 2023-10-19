import 'package:logger/logger.dart';
import 'package:book_repository/book_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._bookRepository) : super(const HomeState());

  final BookRepository _bookRepository;
  final logger = Logger();

  Future<void> getBooks() async {
    emit(state.copyWith(loading: true));
    try {
      final userBooks = await _bookRepository.getBooks();
      emit(state.copyWith(books: userBooks, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
      logger.e("Error getBooks", error: "$e");
    }
  }

  Future<void> addBook() async {
    emit(state.copyWith(loading: true));
    try {
      final newBook = await _bookRepository.uploadBook();
      final savedBook = await _bookRepository.addBook(newBook);
      final savedBookMap = <String, String>{savedBook.id: savedBook.url};
      final Map<String, String> savedBooks = Map.of(state.books)
        ..addEntries(savedBookMap.entries);
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
}
