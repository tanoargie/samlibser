import 'dart:convert';
import 'dart:typed_data';
import 'package:cache/cache.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:epub_view/epub_view.dart';
import 'package:internet_file/internet_file.dart';
import 'package:book_repository/models/book.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DuplicatedRecord implements Exception {
  const DuplicatedRecord();

  static String message = "Duplicated book!";
}

class FileUploadCancelled implements Exception {
  const FileUploadCancelled();

  static String message = "Cancelled upload";
}

class DeleteRecord implements Exception {
  const DeleteRecord();

  static String message = "Could not delete book!";
}

class BookRepository {
  BookRepository(
      {required AuthenticationRepository authenticationRepository,
      CacheClient? cache})
      : _authenticationRepository = authenticationRepository,
        _cache = cache ?? CacheClient();

  final CacheClient _cache;
  final AuthenticationRepository? _authenticationRepository;

  final baseUrl =
      Uri.https(const String.fromEnvironment('BASE_URL'), '/api/books');

  static const booksCacheKey = '__books_cache_key__';
  static const booksPositionsCacheKey = '__books_positions_cache_key__';

  void writeCachedBooks(Map<String, EpubBook> userBooks) {
    _cache.write(key: booksCacheKey, value: userBooks);
  }

  void writeCachedPositions(Map<String, String> userBooksPositions) {
    _cache.write(key: booksPositionsCacheKey, value: userBooksPositions);
  }

  Map<String, String>? getCachedBooksPositions() {
    return _cache.read<Map<String, String>>(key: booksPositionsCacheKey) ??
        null;
  }

  Map<String, EpubBook>? getCachedBooks() {
    return _cache.read<Map<String, EpubBook>>(key: booksCacheKey) ?? null;
  }

  Future<Map<String, String>> getBooksPositionsFromServer() async {
    var token = await _authenticationRepository?.getCurrentUserToken();
    try {
      var response = await http.get(baseUrl, headers: {
        'Authorization': "Bearer $token",
      });
      final responseJson = jsonDecode(response.body);
      List<Book> userBooks = (responseJson["data"] ?? [])
          .map<Book>((json) => Book.fromJson(json))
          .toList();
      Map<String, String> userBooksPositionsMap = {};
      for (int loop = 0; loop < userBooks.length; loop++) {
        userBooksPositionsMap.addEntries([
          MapEntry(userBooks.elementAt(loop).id, userBooks.elementAt(loop).cfi)
        ]);
      }
      writeCachedPositions(userBooksPositionsMap);
      return userBooksPositionsMap;
    } catch (err) {
      throw err;
    }
  }

  Future<Map<String, EpubBook>> getBooksFromServer() async {
    var token = await _authenticationRepository?.getCurrentUserToken();
    try {
      var response = await http.get(baseUrl, headers: {
        'Authorization': "Bearer $token",
      });
      final responseJson = jsonDecode(response.body);
      List<Book> userBooks = (responseJson["data"] ?? [])
          .map<Book>((json) => Book.fromJson(json))
          .toList();
      List<Uint8List> files = await Future.wait<Uint8List>(userBooks.map(
          (book) => InternetFile.get(book.url,
              headers: {"Access-Control-Allow-Origin": "*"})));
      List<EpubBook> books = await Future.wait<EpubBook>(
          files.map((file) => EpubDocument.openData(file)));
      Map<String, EpubBook> userBooksMap = {};
      for (int loop = 0; loop < userBooks.length; loop++) {
        userBooksMap.addEntries(
            [MapEntry(userBooks.elementAt(loop).id, books.elementAt(loop))]);
      }
      writeCachedBooks(userBooksMap);
      return userBooksMap;
    } catch (err) {
      throw err;
    }
  }

  Future<Map<String, String>> getBooksPositions() async {
    var currentPositions = getCachedBooksPositions();
    if (currentPositions != null) {
      return currentPositions;
    } else {
      return getBooksPositionsFromServer();
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
    var token = await _authenticationRepository?.getCurrentUserToken();
    try {
      await http.delete(Uri.parse('$baseUrl/$key'),
          headers: {'Authorization': "Bearer $token"});
      Map<String, EpubBook> cachedEpubs = getCachedBooks() ?? {};
      cachedEpubs.remove(key);
      writeCachedBooks(cachedEpubs);
    } catch (e) {
      throw DeleteRecord();
    }
  }

  Future<void> updateBookPosition(String key, String cfi) async {
    var token = await _authenticationRepository?.getCurrentUserToken();
    try {
      Map<String, String> headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "multipart/form-data;"
      };
      Map<String, String> body = <String, String>{"cfi": cfi};
      var request =
          await http.MultipartRequest("PATCH", Uri.parse('$baseUrl/$key'));
      request.fields.addAll(body);
      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 204) {
        Map<String, String> cachedPositions = getCachedBooksPositions() ?? {};
        cachedPositions[key] = cfi;
        writeCachedPositions(cachedPositions);
      }
    } catch (err) {
      throw err;
    }
  }

  Future<Map<String, EpubBook>> addBook(PlatformFile bookFile) async {
    var token = await _authenticationRepository?.getCurrentUserToken();
    try {
      Map<String, String> headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "multipart/form-data;"
      };
      var request = http.MultipartRequest('POST', baseUrl);
      var file;
      if (kIsWeb) {
        file = await http.MultipartFile.fromBytes(
            'file', bookFile.bytes?.toList() ?? [],
            filename: bookFile.name);
      } else {
        file = await http.MultipartFile.fromPath('file', bookFile.path ?? "",
            filename: bookFile.name);
      }
      request.headers.addAll(headers);
      request.files.add(file);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 409) {
        throw DuplicatedRecord();
      }
      final responseJson = jsonDecode(response.body);
      Book book = Book.fromJson(responseJson['data']);
      final ifile = await InternetFile.get(book.url,
          headers: {"Access-Control-Allow-Origin": "*"});
      final epub = await EpubDocument.openData(ifile);
      final newEpub = <String, EpubBook>{book.id: epub};
      Map<String, EpubBook> cachedEpubs = getCachedBooks() ?? {};
      cachedEpubs.addAll(newEpub);
      writeCachedBooks(cachedEpubs);
      return newEpub;
    } catch (err) {
      throw err;
    }
  }
}
