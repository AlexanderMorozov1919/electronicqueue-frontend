import 'dart:convert';
import 'package:elqueue/config/app_config.dart';
import 'package:http/http.dart' as http;
import '../../../administrator/core/errors/exceptions.dart';
import '../../../administrator/domain/entities/business_process_entity.dart';

class SettingsRemoteDataSource {
  final http.Client client;

  SettingsRemoteDataSource({required this.client});

  Future<List<BusinessProcessEntity>> getProcesses() async {
    final response = await client.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/admin/processes'),
      headers: { 'X-API-KEY': AppConfig.internalApiKey },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => BusinessProcessEntity(
        name: json['process_name'],
        isEnabled: json['is_enabled'],
      )).toList();
    } else {
      throw ServerException('Не удалось загрузить статусы процессов');
    }
  }

  Future<void> updateProcessStatus(String name, bool isEnabled) async {
    final response = await client.patch(
      Uri.parse('${AppConfig.apiBaseUrl}/api/admin/processes/$name'),
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': AppConfig.internalApiKey,
      },
      body: json.encode({'is_enabled': isEnabled}),
    );
    if (response.statusCode != 200) {
      throw ServerException('Не удалось обновить статус процесса');
    }
  }
}