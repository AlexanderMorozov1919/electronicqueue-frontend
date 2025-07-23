import '../../domain/entities/auth_entity.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../config/app_config.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  String? _token;
  Doctor? _doctor;
  static const String _tokenKey = 'auth_token';
  static const String _doctorKey = 'auth_doctor';
  static final String _baseUrl = AppConfig.apiBaseUrl;

  String? get token => _token;
  Doctor? get doctor => _doctor;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    
    final doctorJson = prefs.getString(_doctorKey);
    if (doctorJson != null) {
      try {
        final doctorMap = json.decode(doctorJson) as Map<String, dynamic>;
        _doctor = Doctor(
          id: doctorMap['id'] as String,
          name: doctorMap['name'] as String,
          specialization: doctorMap['specialization'] as String,
        );
      } catch (e) {
        print('Error loading doctor data: $e');
      }
    }
  }

  void setAuthData(String token, Doctor doctor) async {
    _token = token;
    _doctor = doctor;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_doctorKey, json.encode({
      'id': doctor.id,
      'name': doctor.name,
      'specialization': doctor.specialization,
    }));
  }

  void clear() async {
    _token = null;
    _doctor = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_doctorKey);
  }

  Future<int> getDoctorId() async {
    if (_token == null) {
      throw Exception('Токен не найден. Авторизуйтесь.');
    }

    try {
      final payload = JwtDecoder.decode(_token!);
      final doctorId = payload['user_id'] as int?;
      if (doctorId == null) {
        throw Exception('ID врача не найден в токене');
      }
      return doctorId;
    } catch (e) {
      throw Exception('Ошибка получения ID врача: $e');
    }
  }

  Future<void> setDoctorActive() async {
    if (_token == null) {
      throw Exception('Токен не найден. Авторизуйтесь.');
    }

    try {
      final doctorId = await getDoctorId();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/doctor/set-active'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'doctor_id': doctorId}),
      );

      if (response.statusCode != 200) {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        final errorMessage = errorBody['error'] ?? 'Failed to set doctor as active: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Ошибка установки статуса активный: $e');
    }
  }

  Future<void> setDoctorInactive() async {
    if (_token == null) {
      throw Exception('Токен не найден. Авторизуйтесь.');
    }

    try {
      final doctorId = await getDoctorId();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/doctor/set-inactive'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'doctor_id': doctorId}),
      );

      if (response.statusCode != 200) {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        final errorMessage = errorBody['error'] ?? 'Failed to set doctor as inactive: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Ошибка установки статуса неактивный: $e');
    }
  }
}