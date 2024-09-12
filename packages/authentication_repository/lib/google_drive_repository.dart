import 'package:file_picker/file_picker.dart';
import 'package:googleapis/drive/v3.dart' as drive;

mixin class GoogleDriveRepository {
  late final drive.DriveApi _googleDriveApi;

  Future<drive.File> uploadDriveDocument(
      drive.File file, PlatformFile platformFile) async {
    Stream<List<int>>? stream = platformFile.readStream;
    int size = platformFile.size;

    return _googleDriveApi.files
        .create(file, uploadMedia: drive.Media(stream!, size));
  }

  Future<Object?> getDriveDocument(String fileId) async {
    return _googleDriveApi.files
        .get(fileId, downloadOptions: drive.DownloadOptions.fullMedia);
  }

  Future<drive.FileList> getDriveDocuments() async {
    return _googleDriveApi.files.list(spaces: 'appDataFolder');
  }

  Future<void> deleteDriveDocument(String fileId) async {
    return _googleDriveApi.files.delete(fileId);
  }

  Future<drive.File> updateDriveDocument(String id, drive.File file) async {
    return _googleDriveApi.files.update(file, id, $fields: 'appProperties');
  }
}
