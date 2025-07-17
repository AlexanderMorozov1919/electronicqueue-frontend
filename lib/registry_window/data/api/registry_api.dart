import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket_model.dart';

const String _kApiBaseUrl = 'http://localhost:8080';

class RegistryApi {
  final String baseUrl;
  final http.Client client;

  RegistryApi({http.Client? client, String? baseUrl})
      : client = client ?? http.Client(),
        baseUrl = baseUrl ?? _kApiBaseUrl;

  /// Вызывает следующего пациента к указанному окну.
  Future<TicketModel> callNextTicket(int windowNumber) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/registrar/call-next'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({'window_number': windowNumber}),
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      return TicketModel.fromJson(json.decode(responseBody));
    } else if (response.statusCode == 404) {
      throw Exception('Очередь пуста');
    } else {
      throw Exception('Ошибка сервера при вызове талона: ${response.statusCode}');
    }
  }
}
