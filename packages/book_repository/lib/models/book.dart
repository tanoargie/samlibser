import 'package:equatable/equatable.dart';

class Book extends Equatable {
  const Book(this.id, this.url);

  final String id;
  final String url;

  @override
  List<Object> get props => [id, url];

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(json['ID'].toString(), json['URL']);
  }
}
