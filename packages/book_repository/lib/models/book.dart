import 'package:equatable/equatable.dart';

class Book extends Equatable {
  const Book(this.id, this.url, this.cfi);

  final String id;
  final String url;
  final String cfi;

  @override
  List<Object> get props => [id, url, cfi];

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
        json['ID'].toString(), json['URL'].toString(), json['CFI'].toString());
  }
}
