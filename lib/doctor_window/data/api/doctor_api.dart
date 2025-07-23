import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../services/auth_service.dart';

class DoctorApi {
  final http.Client client;
  final AuthService _authService;
  static final String baseUrl = AppConfig.apiBaseUrl;

  DoctorApi({http.Client? client})
      : client = client ?? http.Client(),
        _authService = AuthService();

  Map<String, String> _getHeaders() {
    final token = _authService.token;
    if (token == null) throw Exception('Токен не найден. Авторизуйтесь.');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> getRegisteredTickets() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/doctor/tickets/registered'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') {
        return [];
      }
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load registered tickets: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>?> getCurrentActiveTicket() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/doctor/tickets/in-progress'),
      headers: _getHeaders(),
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

  Future<Map<String, dynamic>> startAppointment(int ticketId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/doctor/start-appointment'),
      headers: _getHeaders(),
      body: json.encode({'ticket_id': ticketId}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data['ticket'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to start appointment: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> completeAppointment(int ticketId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/doctor/complete-appointment'),
      headers: _getHeaders(),
      body: json.encode({'ticket_id': ticketId}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data['ticket'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to complete appointment: ${response.statusCode}');
    }
  }

  Future<void> startBreak(int doctorId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/doctor/start-break'),
      headers: _getHeaders(),
      body: json.encode({'doctor_id': doctorId}),
    );

    if (response.statusCode != 200) {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      final errorMessage = errorBody['error'] ?? 'Failed to start break: ${response.statusCode}';
      throw Exception(errorMessage);
    }
  }

  Future<void> endBreak(int doctorId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/doctor/end-break'),
      headers: _getHeaders(),
      body: json.encode({'doctor_id': doctorId}),
    );

    if (response.statusCode != 200) {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      final errorMessage = errorBody['error'] ?? 'Failed to end break: ${response.statusCode}';
      throw Exception(errorMessage);
    }
  }

  Future<void> setDoctorActive(int doctorId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/doctor/set-active'),
      headers: _getHeaders(),
      body: json.encode({'doctor_id': doctorId}),
    );

    if (response.statusCode != 200) {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      final errorMessage = errorBody['error'] ?? 'Failed to set doctor as active: ${response.statusCode}';
      throw Exception(errorMessage);
    }
  }

  Future<void> setDoctorInactive(int doctorId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/doctor/set-inactive'),
      headers: _getHeaders(),
      body: json.encode({'doctor_id': doctorId}),
    );

    if (response.statusCode != 200) {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      final errorMessage = errorBody['error'] ?? 'Failed to set doctor as inactive: ${response.statusCode}';
      throw Exception(errorMessage);
    }
  }
}
