import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorApi {
  static const String baseUrl = 'http://localhost:8080'; // Измените на ваш URL

  // Получить количество зарегистрированных талонов
  Future<int> getRegisteredTicketsCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/doctor/tickets/registered'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.length; // Возвращаем количество талонов
      } else {
        throw Exception('Failed to load registered tickets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching registered tickets: $e');
    }
  }
} 