import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/ticket_category.dart';
import '../../domain/entities/ticket_entity.dart';
import '../models/ticket_model.dart';
import 'ticket_data_source.dart';
import '../services/auth_token_service.dart';

class TicketRemoteDataSourceImpl implements TicketDataSource {
  final http.Client client;
  final String _baseUrl = AppConfig.apiBaseUrl;
  final AuthTokenService _tokenService = AuthTokenService();

  TicketRemoteDataSourceImpl({required this.client});

  Map<String, String> _getAuthHeaders() {
    final token = _tokenService.token;
    if (token == null) {
      throw ServerException('Пользователь не авторизован');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<TicketEntity> callNextTicket(int windowNumber) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/api/registrar/call-next'),
      headers: _getAuthHeaders(),
      body: json.encode({'window_number': windowNumber}),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      return TicketModel.fromJson(decoded);
    } else if (response.statusCode == 404) {
      throw ServerException('Очередь пуста');
    } else {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      throw ServerException(
        errorBody['error'] ?? 'Ошибка вызова следующего талона',
      );
    }
  }

  @override
  Future<void> updateTicketStatus(String ticketId, String status) async {
    final response = await client.patch(
      Uri.parse('$_baseUrl/api/registrar/tickets/$ticketId/status'),
      headers: _getAuthHeaders(),
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200) {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      throw ServerException(
        errorBody['error'] ?? 'Ошибка обновления статуса талона',
      );
    }
  }

  @override
  Future<List<TicketEntity>> getTicketsByCategory(
    TicketCategory category,
  ) async {
    // Устанавливаем базовое условие для фильтрации по статусам
    final List<Map<String, dynamic>> conditions = [
      {
        "field": "status",
        "operator": "IN",
        "value": ["ожидает", "зарегистрирован", "завершен"]
      }
    ];

    // Добавляем фильтр по категории, если выбрана не "Все категории"
    if (category != TicketCategory.all) {
      String letterPrefix = '';
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
        case TicketCategory.all:
          break;
      }
      conditions.add({
        "field": "ticket_number",
        "operator": "LIKE",
        "value": letterPrefix,
      });
    }

    final requestBody = {
      "page": 1,
      "limit": 1000, // Лимит для получения всех нужных талонов
      "filters": {
        "logical_operator": "AND",
        "conditions": conditions,
      },
    };

    final uri = Uri.parse('$_baseUrl/api/database/tickets/select');
    final headers = {
      'Content-Type': 'application/json',
      'X-API-KEY': AppConfig.externalApiKey,
    };

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(utf8.decode(response.bodyBytes));

      if (decodedResponse is! Map || !decodedResponse.containsKey('data')) {
        throw ServerException("Ответ от сервера не содержит ключ 'data'");
      }

      final List<dynamic> ticketData = decodedResponse['data'] ?? [];
      return ticketData.map((json) => TicketModel.fromJson(json)).toList();
    } else {
      throw ServerException(
        'Не удалось загрузить талоны. Статус: ${response.statusCode}, Тело: ${utf8.decode(response.bodyBytes)}',
      );
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