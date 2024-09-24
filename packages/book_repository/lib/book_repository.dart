import 'package:book_repository/book_repository_client.dart';
import 'package:book_repository/errors.dart';
import 'package:flutter/foundation.dart';
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
      {required AuthenticationRepository? authenticationRepository,
      CacheClient? cache})
      : _authenticationRepository = authenticationRepository,
        _cache = cache ?? CacheClient();

  final CacheClient _cache;
  final AuthenticationRepository? _authenticationRepository;

  static const booksCacheKey = '__books_cache_key__';
  static const booksPositionsCacheKey = '__books_positions_cache_key__';

  Future<T> exceptionHandler<T, E extends Exception>({
    required ValueGetter<Future<T>> tryBlock,
    required E Function({String? error}) makeException,
  }) async {
    int tryCounter = 0;
    try {
      await this._authenticationRepository?.loadGoogleDriveApi();
      return await tryBlock();
    } on AccessDeniedException {
      await this._authenticationRepository?.loadGoogleDriveApi();
      tryCounter++;
      if (tryCounter == 2) {
        rethrow;
      } else {
        return await tryBlock();
      }
    } catch (e) {
      if (e is E) {
        rethrow;
      }

      throw makeException(error: e.toString());
    }
  }

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

  Future<Map<String, EpubBook>> getBooksFromServer() async {
    return await exceptionHandler(
        tryBlock: () async {
          Map<String, EpubBook> userBooksMap = {};
          Map<String, String> userBooksPositionsMap = {};
          drive.FileList? files =
              await _authenticationRepository?.getDriveDocuments();
          if (files?.files != null) {
            for (var file in files!.files!) {
              if (file.id != null) {
                final epubMedia = await _authenticationRepository
                    ?.getDriveDocument(file.id!) as drive.Media;
                EpubBook book =
                    await BookRepositoryClient.getEpubFile(epubMedia);
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
        },
        makeException: GetBooksException.new);
  }

  Future<void> deleteBook(String key) async {
    return await exceptionHandler(
        tryBlock: () async {
          await _authenticationRepository?.deleteDriveDocument(key);
          Map<String, EpubBook> cachedEpubs = getCachedBooks() ?? {};
          Map<String, String> cachedEpubsPositions =
              getCachedBooksPositions() ?? {};
          cachedEpubs.remove(key);
          cachedEpubsPositions.remove(key);
          writeCachedBooks(cachedEpubs);
          writeCacheBooksPositions(cachedEpubsPositions);
        },
        makeException: DeleteRecordException.new);
  }

  Future<void> updateBookPosition(String key, String cfi) async {
    return await exceptionHandler(
        tryBlock: () async {
          Map<String, String> cachedEpubsPositions =
              getCachedBooksPositions() ?? {};
          cachedEpubsPositions[key] = cfi;
          writeCacheBooksPositions(cachedEpubsPositions);
          final file = new drive.File(appProperties: {"cfi": cfi});
          await _authenticationRepository?.updateDriveDocument(key, file);
        },
        makeException: UpdateBookPositionsException.new);
  }

  Future<Map<String, EpubBook>> addBook(PlatformFile bookFile) async {
    return await exceptionHandler(
        tryBlock: () async {
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
        },
        makeException: UploadBookException.new);
  }
}
