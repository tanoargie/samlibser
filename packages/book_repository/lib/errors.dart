class DuplicatedRecord implements Exception {
  const DuplicatedRecord();

  static String message = "Duplicated book!";
}

class FileUploadCancelled implements Exception {
  const FileUploadCancelled();

  static String message = "Cancelled upload!";
}

class DeleteRecordException implements Exception {
  const DeleteRecordException();

  static String message = "Could not delete book!";
}

class UpdateBookPositionsException implements Exception {
  const UpdateBookPositionsException();

  static String message = "Could not update book position!";
}

class UploadBookException implements Exception {
  const UploadBookException();

  static String message = "Could not upload book!";
}

class GetBooksException implements Exception {
  const GetBooksException();

  static String message = "Could not retrieve books!";
}
