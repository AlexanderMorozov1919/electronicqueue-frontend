import 'package:bloc/bloc.dart';
import 'package:elqueue/registry_window/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/auth_entity.dart';
import '../../../domain/usecases/authenticate_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  int? _windowNumber;
  final AuthenticateUser authenticateUser;

  final AuthRepository authRepository;
  int? get windowNumber => _windowNumber;

  AuthBloc({required this.authenticateUser, required this.authRepository}) : super(AuthInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<LogoutRequested>(_onLogoutRequested);
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
          final login = event.authEntity.login;
          final windowNum = int.tryParse(login.replaceAll(RegExp(r'[^0-9]'), ''));
          _windowNumber = windowNum ?? 1;
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
}