import 'dart:convert';
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

  Map<String, EpubBook> getCurrentBooks() {
    return _cache.read<Map<String, EpubBook>>(key: booksCacheKey) ?? Map();
  }

  Future<Map<String, EpubBook>> getBooks() async {
    var token = _authenticationRepository?.currentUser.token;
    var currentEpubs = getCurrentBooks();
    if (currentEpubs.isNotEmpty) {
      return currentEpubs;
    }
    try {
      var response =
          await http.get(baseUrl, headers: {'Authorization': "Bearer $token"});
      final responseJson = jsonDecode(response.body);
      List<dynamic> userBooks = responseJson["data"] ?? [];
      Map<String, EpubBook> userBooksMap = <String, EpubBook>{};
      for (int loop = 0; loop < userBooks.length; loop++) {
        final id = userBooks.elementAt(loop)["ID"].toString();
        final url = userBooks.elementAt(loop)["URL"].toString();
        final file = await InternetFile.get(url);
        final book = await EpubDocument.openData(file);
        userBooksMap.addEntries([MapEntry(id, book)]);
      }
      _cache.write(key: booksCacheKey, value: userBooksMap);
      return userBooksMap;
    } catch (err) {
      throw err;
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

  Future<Map<String, EpubBook>> addBook(PlatformFile bookFile) async {
    var token = _authenticationRepository?.currentUser.token;
    try {
      Map<String, String> headers = {
        "Authorization": "Bearer $token",
        'Content-Type': 'multipart/form-data;',
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
      final ifile = await InternetFile.get(book.url);
      final epub = await EpubDocument.openData(ifile);
      return <String, EpubBook>{book.id: epub};
    } catch (err) {
      throw err;
    }
  }
}
