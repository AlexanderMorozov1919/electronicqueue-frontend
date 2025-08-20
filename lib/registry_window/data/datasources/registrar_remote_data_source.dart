import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/service_entity.dart';
import '../services/auth_token_service.dart';

abstract class RegistrarRemoteDataSource {
  Future<List<ServiceEntity>> getAllServices();
  Future<List<ServiceEntity>> getPriorities();
  Future<void> setPriorities(List<int> serviceIds);
}

class RegistrarRemoteDataSourceImpl implements RegistrarRemoteDataSource {
  final http.Client client;
  final String _baseUrl = AppConfig.apiBaseUrl;
  final AuthTokenService _tokenService = AuthTokenService();

  RegistrarRemoteDataSourceImpl({required this.client});

  Map<String, String> _getAuthHeaders() {
    final token = _tokenService.token;
    if (token == null) throw ServerException('Пользователь не авторизован');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<ServiceEntity>> getAllServices() async {
    final response = await client.get(
      Uri.parse('$_baseUrl/api/registrar/services'),
      headers: _getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => ServiceEntity.fromJson(json)).toList();
    } else {
      throw ServerException('Не удалось загрузить список услуг');
    }
  }

  @override
  Future<List<ServiceEntity>> getPriorities() async {
    final response = await client.get(
      Uri.parse('$_baseUrl/api/registrar/priorities'),
      headers: _getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => ServiceEntity.fromJson(json)).toList();
    } else {
      throw ServerException('Не удалось загрузить приоритеты');
    }
  }

  @override
  Future<void> setPriorities(List<int> serviceIds) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/api/registrar/priorities'),
      headers: _getAuthHeaders(),
      body: json.encode({'service_ids': serviceIds}),
    );
    if (response.statusCode != 200) {
      throw ServerException('Не удалось сохранить приоритеты');
    }
  }
}