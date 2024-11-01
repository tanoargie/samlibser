import 'package:file_picker/file_picker.dart';
import 'package:googleapis/drive/v3.dart' as drive;

mixin class GoogleDriveRepository {
  late drive.DriveApi googleDriveApi;

  Future<drive.File> uploadDriveDocument(
      drive.File file, PlatformFile platformFile) async {
    Stream<List<int>>? stream = platformFile.readStream;
    int size = platformFile.size;

    return googleDriveApi.files
        .create(file, uploadMedia: drive.Media(stream!, size));
  }

  Future<Object?> getDriveDocument(String fileId) async {
    return googleDriveApi.files
        .get(fileId, downloadOptions: drive.DownloadOptions.fullMedia, $fields: '*');
  }

  Future<drive.FileList> getDriveDocuments() async {
    return googleDriveApi.files.list(spaces: 'appDataFolder', $fields: '*');
  }

  Future<void> deleteDriveDocument(String fileId) async {
    return googleDriveApi.files.delete(fileId);
  }

  Future<drive.File> updateDriveDocument(String id, drive.File file) async {
    return googleDriveApi.files.update(file, id, $fields: '*');
  }
}
