import 'package:equatable/equatable.dart';

/// {@template user}
/// User model
///
/// [User.empty] represents an unauthenticated user.
/// {@endtemplate}
class User extends Equatable {
  /// {@macro user}
  const User({required this.id, this.email, this.name, this.token});

  /// The current user's email address.
  final String? email;

  /// The current user's id.
  final String id;

  /// The current user's name (display name).
  final String? name;

  /// The current user's token
  final String? token;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(id: '');

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  User withToken(String token) {
    return User(id: this.id, email: this.email, name: this.email, token: token);
  }

  @override
  List<Object?> get props => [email, id, name, token];
}
