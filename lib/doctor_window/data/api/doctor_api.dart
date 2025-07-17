import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';

class DoctorApi {
  static const String baseUrl = 'http://localhost:8080';

  // Получить список зарегистрированных талонов
  Future<List<Map<String, dynamic>>> getRegisteredTickets() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/doctor/tickets/registered'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Бэкенд может вернуть null, если список пуст
      if (response.body.isEmpty || response.body == 'null') {
        return [];
      }
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception(
        'Failed to load registered tickets: ${response.statusCode}',
      );
    }
  }

  // Получить текущий активный талон (на приеме)
  Future<Map<String, dynamic>?> getCurrentActiveTicket() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/doctor/tickets/in-progress'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') {
        return null;
      }
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data.isNotEmpty) {
        return data.first as Map<String, dynamic>;
      }
      return null;
    } else {
      throw Exception('Failed to get active ticket: ${response.statusCode}');
    }
  }

  // Начать прием пациента
  Future<Map<String, dynamic>> startAppointment(int ticketId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/doctor/start-appointment'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'ticket_id': ticketId}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return data['ticket'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to start appointment: ${response.statusCode}');
    }
  }

  // Завершить прием пациента
  Future<Map<String, dynamic>> completeAppointment(int ticketId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/doctor/complete-appointment'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'ticket_id': ticketId}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return data['ticket'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to complete appointment: ${response.statusCode}');
    }
  }
}
