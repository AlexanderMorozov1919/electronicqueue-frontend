class AuthTokenService {
  // Приватный конструктор
  AuthTokenService._internal();

  static final AuthTokenService _instance = AuthTokenService._internal();

  factory AuthTokenService() {
    return _instance;
  }

  String? _token;

  String? get token => _token;

  void setToken(String? token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }
}