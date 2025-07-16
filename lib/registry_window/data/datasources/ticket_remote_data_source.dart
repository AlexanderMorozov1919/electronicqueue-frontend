import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/app_constans.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/ticket_category.dart';
import '../../domain/entities/ticket_entity.dart';
import '../models/ticket_model.dart';
import 'ticket_data_source.dart';

class TicketRemoteDataSourceImpl implements TicketDataSource {
  final http.Client client;
  final String _baseUrl = AppConstants.apiBaseUrl;

  TicketRemoteDataSourceImpl({required this.client});

  @override
  Future<TicketEntity> callNextTicket(int windowNumber) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/api/registrar/call-next'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'window_number': windowNumber}),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      return TicketModel.fromJson(decoded);
    } else if (response.statusCode == 404) {
      throw ServerException('Очередь пуста');
    } else {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      throw ServerException(errorBody['error'] ?? 'Ошибка вызова следующего талона');
    }
  }

  @override
  Future<void> updateTicketStatus(String ticketId, String status) async {
    final response = await client.patch(
      Uri.parse('$_baseUrl/api/registrar/tickets/$ticketId/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200) {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      throw ServerException(errorBody['error'] ?? 'Ошибка обновления статуса талона');
    }
  }

  @override
  Future<List<TicketEntity>> getTicketsByCategory(TicketCategory category) async {
    String letterPrefix;
    switch (category) {
      case TicketCategory.byAppointment:
        letterPrefix = 'A%';
        break;
      case TicketCategory.makeAppointment:
        letterPrefix = 'B%';
        break;
      case TicketCategory.tests:
        letterPrefix = 'C%';
        break;
      case TicketCategory.other:
        letterPrefix = 'D%';
        break;
    }

    final requestBody = {
      "page": 1,
      "limit": 100,
      "filters": {
        "logical_operator": "AND",
        "conditions": [
          {"field": "ticket_number", "operator": "LIKE", "value": letterPrefix}
        ]
      }
    };

    final uri = Uri.parse('$_baseUrl/api/database/tickets/select');
    final headers = {
      'Content-Type': 'application/json',
      'X-API-KEY': AppConstants.internalApiKey,
    };

    print('>>> REQUEST to $uri');
    print('>>> HEADERS: $headers');
    print('>>> BODY: ${json.encode(requestBody)}');
    
    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(requestBody),
    );

    print('<<< RESPONSE status: ${response.statusCode}');
    print('<<< RESPONSE body: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(utf8.decode(response.bodyBytes));

      if (decodedResponse is! Map || !decodedResponse.containsKey('data')) {
          throw ServerException("Ответ от сервера не содержит ключ 'data'");
      }
      
      final List<dynamic> ticketData = decodedResponse['data'] ?? [];
      return ticketData.map((json) => TicketModel.fromJson(json)).toList();
    } else {
      throw ServerException(
          'Не удалось загрузить талоны. Статус: ${response.statusCode}, Тело: ${utf8.decode(response.bodyBytes)}');
    }
  }

  @override
  Future<TicketEntity?> getCurrentTicket() async {
    return null;
  }

  @override
  Future<List<TicketEntity>> getTickets() async {
    return [];
  }
}