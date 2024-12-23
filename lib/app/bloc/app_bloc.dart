import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/models/user.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(
          authenticationRepository.currentUser.isNotEmpty
              ? AppState.authenticated(authenticationRepository.currentUser)
              : const AppState.unauthenticated(),
        ) {
    on<_AppUserChanged>(_onUserChanged);
    on<AppSelectedIndex>(_onChangeSelectedIndex);
    on<AppLogoutRequested>(_onLogoutRequested);
    _userSubscription = _authenticationRepository.user.listen(
      (user) => add(_AppUserChanged(user)),
    );
  }

  final AuthenticationRepository _authenticationRepository;
  late final StreamSubscription<User> _userSubscription;

  void _onUserChanged(_AppUserChanged event, Emitter<AppState> emit) {
    emit(
      event.user.isEmpty
          ? const AppState.unauthenticated()
          : AppState.authenticated(event.user),
    );
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  void _onChangeSelectedIndex(AppSelectedIndex event, Emitter<AppState> emit) {
    emit(state.changeSelectedIndex(event.selectedMenuIndex));
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // TODO: Logging;
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    // TODO: Logging;
    super.onChange(bloc, change);
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    // TODO: Logging;
    super.onTransition(bloc, transition);
  }
}
