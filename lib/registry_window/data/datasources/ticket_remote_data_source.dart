import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/app_constans.dart';
// Исправлен путь импорта
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
      // Бросаем кастомное исключение, которое будет поймано в репозитории
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
    // Бэкенд возвращает только сообщение, поэтому возвращаем void.
    // BLoC выполнит оптимистичное обновление.
  }

  // Эти методы не используются в текущей логике с API, но должны быть реализованы.
  @override
  Future<TicketEntity?> getCurrentTicket() async {
    // В текущей логике API нет эндпоинта для "получения текущего талона регистратора".
    // "Текущий талон" определяется последним вызванным.
    // Возвращаем null, состояние будет управляться в BLoC.
    return null;
  }

  @override
  Future<List<TicketEntity>> getTickets() async {
    // Этот метод не требуется для основной логики, оставим заглушку
    return [];
  }

  @override
  Future<List<TicketEntity>> getTicketsByCategory(TicketCategory category) async {
    // Этот метод не требуется для основной логики, оставим заглушку
    return [];
  }
}