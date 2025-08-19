part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginButtonPressed extends AuthEvent {
  final AuthEntity authEntity;

  const LoginButtonPressed({required this.authEntity});

  @override
  List<Object> get props => [authEntity];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();

  @override
  List<Object> get props => [];
}

class AuthSessionRestored extends AuthEvent {
  final int windowNumber;
  const AuthSessionRestored({required this.windowNumber});

  @override
  List<Object> get props => [windowNumber];
}