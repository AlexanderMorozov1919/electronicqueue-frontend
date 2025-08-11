import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/ticket_category.dart';
import '../../domain/entities/daily_report_row_entity.dart';
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
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<DailyReportRowEntity>> getDailyReport() async {
    final uri = Uri.parse('$_baseUrl/api/registrar/reports/daily');
    final response = await client.get(uri, headers: _getAuthHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => DailyReportRowEntity.fromJson(json)).toList();
    } else {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      throw ServerException(errorBody['error'] ?? 'Не удалось загрузить отчет');
    }
  }

  @override
  Future<TicketEntity> callNextTicket(int windowNumber, String? categoryPrefix) async {
    final body = <String, dynamic>{
      'window_number': windowNumber,
    };
    if (categoryPrefix != null && categoryPrefix.isNotEmpty) {
      body['category_prefix'] = categoryPrefix;
    }

    final response = await client.post(
      Uri.parse('$_baseUrl/api/registrar/call-next'),
      headers: _getAuthHeaders(),
      body: json.encode(body),
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
  Future<TicketEntity> callSpecificTicket(String ticketId, int windowNumber) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/api/registrar/call-specific'),
      headers: _getAuthHeaders(),
      body: json.encode({
        'ticket_id': int.parse(ticketId),
        'window_number': windowNumber,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      return TicketModel.fromJson(decoded);
    } else {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      throw ServerException(errorBody['error'] ?? 'Ошибка вызова конкретного талона');
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
  Future<List<TicketEntity>> getTicketsByCategory(TicketCategory category) async {
    String categoryPrefix = '';
    switch (category) {
      case TicketCategory.makeAppointment:
        categoryPrefix = 'A';
        break;
      case TicketCategory.byAppointment:
        categoryPrefix = 'B';
        break;
      case TicketCategory.tests:
        categoryPrefix = 'C';
        break;
      case TicketCategory.other:
        categoryPrefix = 'D';
        break;
      case TicketCategory.all:
        break;
    }

    final Map<String, String> queryParams = {};
    if (categoryPrefix.isNotEmpty) {
      queryParams['category'] = categoryPrefix;
    }

    final uri = Uri.parse('$_baseUrl/api/registrar/tickets').replace(queryParameters: queryParams);

    final response = await client.get(
      uri,
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> ticketData = json.decode(utf8.decode(response.bodyBytes));
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