import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorApi {
  static const String baseUrl = 'http://localhost:8080';

  // Получить список зарегистрированных талонов
  Future<List<Map<String, dynamic>>> getRegisteredTickets() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/doctor/tickets/registered'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load registered tickets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching registered tickets: $e');
    }
  }

  // Получить количество зарегистрированных талонов
  Future<int> getRegisteredTicketsCount() async {
    final tickets = await getRegisteredTickets();
    return tickets.length;
  }

  // Начать прием пациента
  Future<Map<String, dynamic>> startAppointment(int ticketId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/doctor/start-appointment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ticket_id': ticketId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['ticket'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to start appointment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error starting appointment: $e');
    }
  }

  // Завершить прием пациента
  Future<Map<String, dynamic>> completeAppointment(int ticketId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/doctor/complete-appointment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ticket_id': ticketId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['ticket'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to complete appointment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error completing appointment: $e');
    }
  }
} 