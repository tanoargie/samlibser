import 'package:equatable/equatable.dart';

class Book extends Equatable {
  const Book(this.id, this.location);

  final String id;
  final String location;

  @override
  List<Object> get props => [id, location];

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(json['ID'].toString(), json['Location']);
  }
}
