import '../../../domain/entities/auth_entity.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class SignInRequested extends AuthEvent {
  final AuthCredentials credentials;

  const SignInRequested(this.credentials);
}

class SignOutRequested extends AuthEvent {}