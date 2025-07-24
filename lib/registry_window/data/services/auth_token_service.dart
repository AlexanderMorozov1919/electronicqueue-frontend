import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenService {
  AuthTokenService._internal();
  static final AuthTokenService _instance = AuthTokenService._internal();
  factory AuthTokenService() => _instance;

  static const String _tokenKey = 'auth_token_registrar';
  String? _token;

  String? get token => _token;

  // Метод для инициализации сервиса при старте приложения
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  // Сохраняем токен в переменную и в хранилище
  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    } else {
      await prefs.remove(_tokenKey);
    }
  }

  // Очищаем токен из переменной и из хранилища
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
