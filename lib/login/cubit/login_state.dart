part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.email = "",
    this.validated = false,
    this.errorMessage = "",
    this.inProgress = false,
  });

  final String email;
  final bool validated;
  final bool inProgress;
  final String errorMessage;

  @override
  List<Object> get props => [email, validated, errorMessage, inProgress];

  LoginState copyWith({
    String? email,
    bool? inProgress,
    bool? validated,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      inProgress: inProgress ?? this.inProgress,
      validated: validated ?? this.validated,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}