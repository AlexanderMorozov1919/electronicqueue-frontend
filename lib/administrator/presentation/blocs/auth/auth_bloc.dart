import 'package:bloc/bloc.dart';
import 'package:elqueue/administrator/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/auth_entity.dart';
import '../../../domain/usecases/authenticate_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthenticateUser authenticateUser;
  final AuthRepository authRepository;

  AuthBloc({required this.authenticateUser, required this.authRepository}) : super(AuthInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthSessionRestored>(_onAuthSessionRestored);
  }

  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await authenticateUser(event.authEntity);
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (success) {
          emit(AuthSuccess());
        },
      );
    } catch (e) {
      emit(AuthError('Произошла ошибка при авторизации'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(AuthInitial());
  }

  void _onAuthSessionRestored(
    AuthSessionRestored event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthSuccess());
  }
}