import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/patient_entity.dart';
import '../services/auth_token_service.dart';

abstract class PatientRemoteDataSource {
  Future<List<PatientEntity>> searchPatients(String query); 
  Future<PatientEntity> createPatient(Map<String, dynamic> patientData);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final http.Client client;
  final String _baseUrl = AppConfig.apiBaseUrl;
  final AuthTokenService _tokenService = AuthTokenService();

  PatientRemoteDataSourceImpl({required this.client});

  Map<String, String> _getAuthHeaders() {
    final token = _tokenService.token;
    if (token == null) throw ServerException('Пользователь не авторизован');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<PatientEntity>> searchPatients(String query) async { 
    final uri = Uri.parse('$_baseUrl/api/registrar/patients/search').replace(queryParameters: {'query': query}); 
    final response = await client.get(uri, headers: _getAuthHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => PatientEntity.fromJson(json)).toList();
    } else {
      throw ServerException('Ошибка поиска пациентов');
    }
  }

  @override
  Future<PatientEntity> createPatient(Map<String, dynamic> patientData) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/api/registrar/patients'),
      headers: _getAuthHeaders(),
      body: json.encode(patientData),
    );

    if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return PatientEntity.fromJson(data);
    } else {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      throw ServerException(errorBody['error'] ?? 'Не удалось создать пациента');
    }
  }
}