part of 'app_bloc.dart';

sealed class AppEvent {
  const AppEvent();
}

final class AppLogoutRequested extends AppEvent {
  const AppLogoutRequested();
}

final class AppSelectedIndex extends AppEvent {
  const AppSelectedIndex(this.selectedMenuIndex);

  final int selectedMenuIndex;
}

final class _AppUserChanged extends AppEvent {
  const _AppUserChanged(this.user);

  final User user;
}
