part of 'app_bloc.dart';

enum AppStatus {
  authenticated,
  unauthenticated,
}

final class AppState extends Equatable {
  const AppState._(
      {required this.status,
      this.user = User.empty,
      this.selectedMenuIndex = 0});

  const AppState.authenticated(User user)
      : this._(status: AppStatus.authenticated, user: user);

  const AppState.unauthenticated() : this._(status: AppStatus.unauthenticated);

  const AppState.changeSelectedIndex(int newIndex)
      : this._(status: AppStatus.authenticated, selectedMenuIndex: newIndex);

  final AppStatus status;
  final User user;
  final int selectedMenuIndex;

  @override
  List<Object> get props => [status, user, selectedMenuIndex];
}
