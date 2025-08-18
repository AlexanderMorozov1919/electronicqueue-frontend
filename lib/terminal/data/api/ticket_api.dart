import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../../domain/entities/service_entity.dart';

class TicketApi {
  final String baseUrl = AppConfig.apiBaseUrl;

  Future<Map<String, dynamic>> fetchStartPage() async {
    final response = await http.get(Uri.parse('$baseUrl/api/tickets/start'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load start page');
    }
  }

  Future<List<ServiceEntity>> fetchServices() async {
    final response = await http.get(Uri.parse('$baseUrl/api/tickets/services'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is! Map || !decoded.containsKey('services')) {
        throw Exception('Некорректный формат ответа: нет ключа services');
      }
      final List services = decoded['services'];
      return services
          .map((e) => ServiceEntity(
                id: e['service_id'],
                title: e['title'],
                letter: e['letter'],
              ))
          .toList();
    } else {
      throw Exception('Failed to load services');
    }
  }

  Future<Map<String, dynamic>> selectService(String serviceId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/tickets/print/selection'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'service_id': serviceId}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to select service');
    }
  }

  Future<Map<String, dynamic>> confirmAction(String serviceId, String action) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/tickets/print/confirmation'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'service_id': serviceId, 'action': action}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to confirm action');
    }
  }

  Future<Map<String, dynamic>> checkInByPhone(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/tickets/appointment/phone'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({'phone': phone}),
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 404) {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(errorBody['error'] ?? 'Запись не найдена');
    } else {
      throw Exception('Ошибка сервера при проверке записи');
    }
  }
}