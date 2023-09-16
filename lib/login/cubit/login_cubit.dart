import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository) : super(const LoginState());

  final AuthenticationRepository _authenticationRepository;

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(inProgress: true));
    try {
      await _authenticationRepository.logInWithGoogle();
      emit(state.copyWith(inProgress: false));
    } on LogInWithGoogleFailure catch (e) {
      emit(
        state.copyWith(
          inProgress: false,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(inProgress: false, errorMessage: "Unknown error"));
    }
  }
}
