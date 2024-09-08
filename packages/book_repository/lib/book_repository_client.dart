import 'dart:async';
import 'package:epubx/epubx.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class BookRepositoryClient {
  static Future<EpubBook> getEpubFile(drive.Media mediaFile) async {
    List<int> datastore = [];
    final Completer<EpubBook> completer = new Completer<EpubBook>();
    await mediaFile.stream.listen((data) {
      datastore.insertAll(datastore.length, data);
    }, onDone: () async {
      final book = await EpubReader.readBook(datastore);
      completer.complete(book);
    });
    return completer.future;
  }
}
