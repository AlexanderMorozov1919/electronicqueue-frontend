import '../../domain/entities/auth_entity.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  String? _token;
  Doctor? _doctor;

  String? get token => _token;
  Doctor? get doctor => _doctor;

  void setAuthData(String token, Doctor doctor) {
    _token = token;
    _doctor = doctor;
  }

  void clear() {
    _token = null;
    _doctor = null;
  }
}