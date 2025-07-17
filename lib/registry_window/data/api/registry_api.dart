import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../models/ticket_model.dart';

class RegistryApi {
  final http.Client client;

  RegistryApi({http.Client? client})
      : client = client ?? http.Client();

  Future<TicketModel> callNextTicket(int windowNumber) async {
    final response = await client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/registrar/call-next'),
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