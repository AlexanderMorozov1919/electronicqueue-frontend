import 'package:bloc/bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/sign_in.dart';
import '../../../data/services/auth_service.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final AuthRepository authRepository;
  final AuthService authService = AuthService();

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
      await result.fold(
        (failure) async {
          emit(AuthFailure(errorMessage: 'Ошибка авторизации'));
        },
        (doctor) async {
          try {
            await authService.setDoctorActive();
            if (!emit.isDone) {
              emit(AuthSuccess(doctor: doctor));
            }
          } catch (e) {
            if (!emit.isDone) {
              emit(AuthSuccess(doctor: doctor));
            }
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(AuthFailure(errorMessage: 'Неизвестная ошибка'));
      }
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      try {
        await authService.setDoctorInactive();
      } catch (e) {
      }
      
      await authRepository.signOut();
      if (!emit.isDone) {
        emit(AuthInitial());
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(AuthFailure(errorMessage: 'Ошибка при выходе'));
      }
    }
  }
}