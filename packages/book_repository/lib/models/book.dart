import 'package:equatable/equatable.dart';

class Book extends Equatable {
  const Book(this.id, this.name, this.author);

  final String id;
  final String name;
  final String author;

  @override
  List<Object> get props => [id, name, author];

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(json['id'], json['name'], json['author']);
  }
}
