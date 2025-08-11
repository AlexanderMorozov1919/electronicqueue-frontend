import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../../core/errors/exceptions.dart';
import '../services/auth_token_service.dart';

abstract class SettingsDataSource {
  Future<bool> isProcessEnabled(String processName);
}

class SettingsRemoteDataSourceImpl implements SettingsDataSource {
  final http.Client client;
  final String _baseUrl = AppConfig.apiBaseUrl;
  final AuthTokenService _tokenService = AuthTokenService();

  SettingsRemoteDataSourceImpl({required this.client});
  
  Map<String, String> _getAuthHeaders() {
    final token = _tokenService.token;
    if (token == null) throw ServerException('Пользователь не авторизован');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<bool> isProcessEnabled(String processName) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/api/processes/$processName'),
      headers: _getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['is_enabled'] as bool;
    } else {
      throw ServerException('Не удалось получить статус процесса');
    }
  }
}