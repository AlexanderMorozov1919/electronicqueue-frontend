import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../../domain/entities/auth_entity.dart';
import '../services/auth_service.dart';

class AuthRemoteDataSource {
  final http.Client client;
  final AuthService authService;

  AuthRemoteDataSource({http.Client? client})
    : client = client ?? http.Client(),
      authService = AuthService();

  Future<Doctor> signIn(AuthCredentials credentials) async {
    final response = await client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/auth/login/doctor'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'login': credentials.login,
        'password': credentials.password,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final token = data['token'] as String;
      final doctorData = data['doctor'] as Map<String, dynamic>;
      final doctor = Doctor(
        id: doctorData['id'].toString(),
        name: doctorData['full_name'],
        specialization: doctorData['specialization'],
      );

      authService.setAuthData(token, doctor);
      return doctor;
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(data['error'] ?? 'Ошибка авторизации');
    }
  }

  Future<void> signOut() async {
    authService.clear();
  }
}
