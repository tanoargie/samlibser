import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:book_repository/models/book.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class SamserBookRepository {
  final baseUrl = Uri.https('samlibser-api.samser.co', '/api/books');
}

class BookRepository extends SamserBookRepository {
  Future<Map<String, Book>> getBooks() async {
    var tokenResult =
        await FirebaseAuth.instance.currentUser?.getIdTokenResult();
    var token = tokenResult?.token;
    var response =
        await http.get(baseUrl, headers: {'Authorization': "Bearer ${token}"});
    final responseJson = jsonDecode(response.body);
    List<dynamic> userBooks = responseJson.books;
    Map<String, Book> userBooksMap = Map();
    for (int loop = 0; loop < userBooks.length; loop++) {
      userBooksMap.addEntries(
          [MapEntry(userBooks[loop].id, Book.fromJson(userBooks[loop]))]);
    }
    return userBooksMap;
  }

  Future<PlatformFile> uploadBook() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );

    if (result != null) {
      return result.files.single;
    } else {
      throw Exception("Cancelled file picker");
    }
  }

  Future<Book> addBook(PlatformFile bookFile) async {
    try {
      var tokenResult =
          await FirebaseAuth.instance.currentUser?.getIdTokenResult();
      var token = tokenResult?.token;
      Map<String, String> headers = {
        "Authorization": "Bearer ${token}",
        'Content-Type': 'multipart/form-data;',
      };
      var request = http.MultipartRequest('POST', baseUrl);
      var file = await http.MultipartFile.fromPath('file', bookFile.path ?? "",
          filename: bookFile.name);
      request.headers.addAll(headers);
      request.files.add(file);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final responseJson = jsonDecode(response.body);
      Book book = responseJson.book;
      return book;
    } catch (err) {
      throw Exception("error");
    }
  }
}
