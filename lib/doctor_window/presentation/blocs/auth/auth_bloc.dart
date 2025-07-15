import 'package:bloc/bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/sign_in.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final AuthRepository authRepository;

  AuthBloc({
    required this.signIn,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await signIn(event.credentials);
      result.fold(
        (failure) => emit(AuthFailure(errorMessage: 'Ошибка авторизации')),
        (doctor) => emit(AuthSuccess(doctor: doctor)),
      );
    } catch (e) {
      emit(AuthFailure(errorMessage: 'Неизвестная ошибка'));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(errorMessage: 'Ошибка при выходе'));
    }
  }
}