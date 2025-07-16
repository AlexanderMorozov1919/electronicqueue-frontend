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

  // Получить текущий активный талон
  Future<Map<String, dynamic>?> getCurrentActiveTicket() async {
    try {
      print('DEBUG: Getting current active ticket');
      final response = await http.get(
        Uri.parse('$baseUrl/api/doctor/tickets/in-progress'),
        headers: {'Content-Type': 'application/json'},
      );

      print('DEBUG: Get active ticket response status: ${response.statusCode}');
      print('DEBUG: Get active ticket response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data.first as Map<String, dynamic>;
        }
        return null;
      } else {
        throw Exception('Failed to get active ticket: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error getting active ticket: $e');
      throw Exception('Error getting active ticket: $e');
    }
  }

  // Завершить прием пациента
  Future<Map<String, dynamic>> completeAppointment(int ticketId) async {
    try {
      print('DEBUG: Completing appointment for ticket ID: $ticketId');
      final response = await http.post(
        Uri.parse('$baseUrl/api/doctor/complete-appointment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ticket_id': ticketId}),
      );

      print('DEBUG: Complete appointment response status: ${response.statusCode}');
      print('DEBUG: Complete appointment response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['ticket'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to complete appointment: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error completing appointment: $e');
      throw Exception('Error completing appointment: $e');
    }
  }
} 