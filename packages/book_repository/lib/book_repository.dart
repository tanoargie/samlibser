import 'package:book_repository/book_repository_client.dart';
import 'package:book_repository/errors.dart';
import 'package:cache/cache.dart';
import 'package:path/path.dart' as p;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:epubx/epubx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:authentication_repository/authentication_repository.dart';

class BookRepository {
  BookRepository(
      {required AuthenticationRepository authenticationRepository,
      CacheClient? cache})
      : _authenticationRepository = authenticationRepository,
        _cache = cache ?? CacheClient();

  final CacheClient _cache;
  final AuthenticationRepository? _authenticationRepository;

  static const booksCacheKey = '__books_cache_key__';
  static const booksPositionsCacheKey = '__books_positions_cache_key__';

  void writeCachedBooks(Map<String, EpubBook> userBooks) {
    _cache.write(key: booksCacheKey, value: userBooks);
  }

  void writeCacheBooksPositions(Map<String, String> userBooksPositions) {
    _cache.write(key: booksPositionsCacheKey, value: userBooksPositions);
  }

  Map<String, String>? getCachedBooksPositions() {
    return _cache.read<Map<String, String>>(key: booksPositionsCacheKey) ??
        null;
  }

  Map<String, EpubBook>? getCachedBooks() {
    return _cache.read<Map<String, EpubBook>>(key: booksCacheKey) ?? null;
  }

  Future<drive.File> uploadDriveDocument(
      drive.File file, PlatformFile platformFile) async {
    Stream<List<int>>? stream = platformFile.readStream;
    int size = platformFile.size;

    return _authenticationRepository!.googleDriveApi!.files
        .create(file, uploadMedia: drive.Media(stream!, size));
  }

  Future<drive.FileList> getDriveDocuments() async {
    return _authenticationRepository!.googleDriveApi!.files.list();
  }

  Future<void> deleteDriveDocument(String fileId) async {
    return _authenticationRepository!.googleDriveApi!.files.delete(fileId);
  }

  Future<drive.File> updateDriveDocument(drive.File file) async {
    return _authenticationRepository!.googleDriveApi!.files
        .update(file, file.id!);
  }

  Future<Map<String, EpubBook>> getBooksFromServer() async {
    try {
      Map<String, EpubBook> userBooksMap = {};
      Map<String, String> userBooksPositionsMap = {};
      drive.FileList files = await getDriveDocuments();
      files.files?.forEach((file) async {
        if (file.webContentLink != null && file.id != null) {
          EpubBook book =
              await BookRepositoryClient.getEpubFile(file.webContentLink!);
          userBooksMap.addEntries([MapEntry(file.id!, book)]);
          if (file.appProperties != null &&
              file.appProperties!.containsKey('cfi')) {
            userBooksPositionsMap
                .addEntries([MapEntry(file.id!, file.appProperties!['cfi']!)]);
          }
        }
      });
      writeCachedBooks(userBooksMap);
      writeCacheBooksPositions(userBooksPositionsMap);
      return userBooksMap;
    } catch (err) {
      throw err;
    }
  }

  Future<Map<String, EpubBook>> getBooks() async {
    var currentEpubs = getCachedBooks();
    if (currentEpubs != null) {
      return currentEpubs;
    } else {
      return getBooksFromServer();
    }
  }

  Future<PlatformFile> uploadBook() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );

    if (result != null) {
      return result.files.single;
    } else {
      throw FileUploadCancelled();
    }
  }

  Future<void> deleteBook(String key) async {
    try {
      await deleteDriveDocument(key);
      Map<String, EpubBook> cachedEpubs = getCachedBooks() ?? {};
      Map<String, String> cachedEpubsPositions =
          getCachedBooksPositions() ?? {};
      cachedEpubs.remove(key);
      cachedEpubsPositions.remove(key);
      writeCachedBooks(cachedEpubs);
      writeCacheBooksPositions(cachedEpubsPositions);
    } catch (e) {
      throw DeleteRecordException();
    }
  }

  Future<void> updateBookPosition(String key, String cfi) async {
    try {
      Map<String, String> cachedEpubsPositions =
          getCachedBooksPositions() ?? {};
      cachedEpubsPositions[key] = cfi;
      writeCacheBooksPositions(cachedEpubsPositions);
      drive.FileList files = await getDriveDocuments();
      drive.File? file =
          files.files?.firstWhere((element) => element.id == key);
      if (file != null) {
        file.appProperties!['cfi'] = cfi;
        await updateDriveDocument(file);
      }
    } catch (err) {
      throw UpdateBookPositionsException();
    }
  }

  Future<Map<String, EpubBook>> addBook(PlatformFile bookFile) async {
    try {
      drive.File fileToUpload = drive.File();
      fileToUpload.name = p.basename(bookFile.path!);
      drive.File newFile = await uploadDriveDocument(
        fileToUpload,
        bookFile,
      );
      final epub =
          await BookRepositoryClient.getEpubFile(newFile.webContentLink!);
      final newEpub = <String, EpubBook>{newFile.id!: epub};
      Map<String, EpubBook> cachedEpubs = getCachedBooks() ?? {};
      cachedEpubs.addAll(newEpub);
      writeCachedBooks(cachedEpubs);
      return newEpub;
    } catch (err) {
      throw err;
    }
  }
}
