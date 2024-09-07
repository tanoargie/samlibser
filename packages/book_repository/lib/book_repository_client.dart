import 'package:epubx/epubx.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class BookRepositoryClient {
  static Future<EpubBook> getEpubFile(drive.Media mediaFile) async {
    final data = await mediaFile.stream.first;
    return EpubReader.readBook(data);
  }
}
