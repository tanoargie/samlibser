import 'package:book_repository/book_repository_client.dart';
import 'package:book_repository/errors.dart';
import 'package:cache/cache.dart';
import 'package:path/path.dart' as p;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart'
    show AccessDeniedException;
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

  Future<Map<String, EpubBook>> getBooksFromServer() async {
    int tryCounter = 0;
    try {
      Map<String, EpubBook> userBooksMap = {};
      Map<String, String> userBooksPositionsMap = {};
      drive.FileList? files =
          await _authenticationRepository?.getDriveDocuments();
      if (files?.files != null) {
        for (var file in files!.files!) {
          if (file.id != null) {
            final epubMedia = await _authenticationRepository
                ?.getDriveDocument(file.id!) as drive.Media;
            EpubBook book = await BookRepositoryClient.getEpubFile(epubMedia);
            userBooksMap.addEntries([MapEntry(file.id!, book)]);
            if (file.appProperties != null &&
                file.appProperties!.containsKey('cfi')) {
              userBooksPositionsMap.addEntries(
                  [MapEntry(file.id!, file.appProperties!['cfi']!)]);
            }
          }
        }
      }
      writeCachedBooks(userBooksMap);
      writeCacheBooksPositions(userBooksPositionsMap);
      return userBooksMap;
    } on AccessDeniedException {
      await _authenticationRepository?.loadGoogleDriveApi();
      tryCounter++;
      if (tryCounter == 2) {
        throw GetBooksException();
      } else {
        return getBooksFromServer();
      }
    } catch (e) {
      print(e);
      throw GetBooksException();
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
      withReadStream: true,
      allowedExtensions: ['epub'],
    );

    if (result != null) {
      return result.files.single;
    } else {
      throw FileUploadCancelled();
    }
  }

  Future<void> deleteBook(String key) async {
    int tryCounter = 0;
    try {
      await _authenticationRepository?.deleteDriveDocument(key);
      Map<String, EpubBook> cachedEpubs = getCachedBooks() ?? {};
      Map<String, String> cachedEpubsPositions =
          getCachedBooksPositions() ?? {};
      cachedEpubs.remove(key);
      cachedEpubsPositions.remove(key);
      writeCachedBooks(cachedEpubs);
      writeCacheBooksPositions(cachedEpubsPositions);
    } on AccessDeniedException {
      await _authenticationRepository?.loadGoogleDriveApi();
      tryCounter++;
      if (tryCounter == 2) {
        throw DeleteRecordException();
      } else {
        return deleteBook(key);
      }
    } catch (e) {
      throw DeleteRecordException();
    }
  }

  Future<void> updateBookPosition(String key, String cfi) async {
    int tryCounter = 0;
    try {
      Map<String, String> cachedEpubsPositions =
          getCachedBooksPositions() ?? {};
      cachedEpubsPositions[key] = cfi;
      writeCacheBooksPositions(cachedEpubsPositions);
      final file = new drive.File(appProperties: {"cfi": cfi});
      await _authenticationRepository?.updateDriveDocument(key, file);
    } on AccessDeniedException {
      await _authenticationRepository?.loadGoogleDriveApi();
      tryCounter++;
      if (tryCounter == 2) {
        throw UpdateBookPositionsException();
      } else {
        return updateBookPosition(key, cfi);
      }
    } catch (err) {
      throw UpdateBookPositionsException();
    }
  }

  Future<Map<String, EpubBook>> addBook(PlatformFile bookFile) async {
    int tryCounter = 0;
    try {
      drive.File fileToUpload = drive.File();
      fileToUpload.name = p.basename(bookFile.path!);
      fileToUpload.parents = ['appDataFolder'];
      drive.File? newFile =
          await _authenticationRepository?.uploadDriveDocument(
        fileToUpload,
        bookFile,
      );
      final epubMedia = await _authenticationRepository
          ?.getDriveDocument(newFile!.id!) as drive.Media;
      final epub = await BookRepositoryClient.getEpubFile(epubMedia);
      final newEpub = <String, EpubBook>{newFile!.id!: epub};
      Map<String, EpubBook> cachedEpubs = getCachedBooks() ?? {};
      cachedEpubs.addAll(newEpub);
      writeCachedBooks(cachedEpubs);
      return newEpub;
    } on AccessDeniedException {
      await _authenticationRepository?.loadGoogleDriveApi();
      tryCounter++;
      if (tryCounter == 2) {
        throw UploadBookException();
      } else {
        return addBook(bookFile);
      }
    } catch (err) {
      throw UploadBookException();
    }
  }
}
