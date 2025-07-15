import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket_model.dart';

// URL вашего бэкенда.
const String _kApiBaseUrl = 'http://localhost:8080';

class RegistryApi {
  final String baseUrl;
  final http.Client client;

  RegistryApi({http.Client? client, String? baseUrl})
      : client = client ?? http.Client(),
        baseUrl = baseUrl ?? _kApiBaseUrl;

  /// Вызывает следующего пациента к указанному окну.
  /// Это ЕДИНСТВЕННЫЙ метод, который мы реализуем сейчас.
  Future<TicketModel> callNextTicket(int windowNumber) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/registrar/call-next'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({'window_number': windowNumber}),
    );

    if (response.statusCode == 200) {
      // Go бэкенд отдает UTF-8, поэтому декодируем правильно
      final responseBody = utf8.decode(response.bodyBytes);
      return TicketModel.fromJson(json.decode(responseBody));
    } else if (response.statusCode == 404) {
      // Сервер явно сказал, что очередь пуста
      throw Exception('Очередь пуста');
    } else {
      // Другая ошибка сервера
      throw Exception('Ошибка сервера при вызове талона: ${response.statusCode}');
    }
  }
}