class DuplicatedRecord implements Exception {
  const DuplicatedRecord({String? error})
      : message = error ?? "Duplicated book!";

  final String message;
}

class FileUploadCancelled implements Exception {
  const FileUploadCancelled({String? error})
      : message = error ?? "Cancelled upload!";

  final String message;
}

class DeleteRecordException implements Exception {
  const DeleteRecordException({String? error})
      : message = error ?? "Could not delete book!";

  final String message;
}

class UpdateBookPositionsException implements Exception {
  const UpdateBookPositionsException({String? error})
      : message = error ?? "Could not update book position!";

  final String message;
}

class UploadBookException implements Exception {
  const UploadBookException({String? error})
      : message = error ?? "Could not upload book!";

  final String message;
}

class GetBooksException implements Exception {
  const GetBooksException({String? error})
      : message = error ?? "Could not retrieve books!";

  final String message;
}
