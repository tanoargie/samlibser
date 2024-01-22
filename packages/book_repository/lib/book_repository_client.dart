import 'package:epubx/epubx.dart';
import 'package:http/http.dart';

class BookRepositoryClient {
  static Future<EpubBook> getEpubFile(String url) async {
    List<int> bookBytes = await readBytes(Uri.parse(url),
        headers: {"Access-Control-Allow-Origin": "*"});
    EpubBook book = await EpubReader.readBook(bookBytes);
    return book;
  }
}
