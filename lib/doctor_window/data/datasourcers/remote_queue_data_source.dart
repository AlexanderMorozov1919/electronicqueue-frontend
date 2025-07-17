import 'dart:async';
import 'dart:convert';
import '../../domain/entities/queue_entity.dart';
import '../models/queue_model.dart';
import '../api/doctor_api.dart';
import 'queue_data_source.dart';
import '../../core/errors/exceptions.dart';

import 'package:http/http.dart' as http;

class RemoteQueueDataSource implements QueueDataSource {
  final DoctorApi api;
  final http.Client _client;

  RemoteQueueDataSource({required this.api, http.Client? client})
    : _client = client ?? http.Client();

  @override
  Future<QueueEntity> getQueueStatus() async {
    final activeTicket = await api.getCurrentActiveTicket();

    if (activeTicket != null) {
      return QueueModel(
        isAppointmentInProgress: true,
        queueLength: 0,
        currentTicket: activeTicket['ticket_number'] as String?,
        activeTicketId: activeTicket['id'] as int?,
      );
    } else {
      final registeredTickets = await api.getRegisteredTickets();
      return QueueModel(
        isAppointmentInProgress: false,
        queueLength: registeredTickets.length,
        currentTicket: null,
        activeTicketId: null,
      );
    }
  }

  @override
  Future<QueueEntity> startAppointment(String ticket) async {
    final tickets = await api.getRegisteredTickets();

    if (tickets.isEmpty) {
      throw EmptyQueueException();
    }

    final nextTicket = tickets.first;
    final ticketId = nextTicket['id'] as int;

    final result = await api.startAppointment(ticketId);

    return QueueModel(
      isAppointmentInProgress: true,
      queueLength: tickets.length - 1,
      currentTicket: result['ticket_number'] as String?,
      activeTicketId: result['id'] as int?,
    );
  }

  @override
  Future<QueueEntity> endAppointment() async {
    final activeTicket = await api.getCurrentActiveTicket();
    if (activeTicket == null) {
      throw Exception('Нет активного приема для завершения');
    }

    final ticketId = activeTicket['id'] as int;
    await api.completeAppointment(ticketId);

    final registeredTickets = await api.getRegisteredTickets();
    return QueueModel(
      isAppointmentInProgress: false,
      queueLength: registeredTickets.length,
      currentTicket: null,
      activeTicketId: null,
    );
  }

  @override
  Stream<void> ticketUpdates() {
    final controller = StreamController<void>();

    void connect() async {
      print("Doctor SSE: Connecting...");
      try {
        final request = http.Request(
          'GET',
          Uri.parse('${DoctorApi.baseUrl}/tickets'),
        );
        request.headers['Accept'] = 'text/event-stream';
        request.headers['Cache-Control'] = 'no-cache';

        final response = await _client.send(request);

        if (response.statusCode == 200) {
          print("Doctor SSE: Connected successfully.");
          response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .listen(
                (line) {
                  if (line.startsWith('data:')) {
                    print("Doctor SSE: Received update event. Notifying BLoC.");
                    controller.add(null);
                  }
                },
                onDone: () {
                  print("Doctor SSE: Stream closed. Reconnecting...");
                  Future.delayed(const Duration(seconds: 5), connect);
                },
                onError: (e, s) {
                  print("Doctor SSE: Stream error. Reconnecting... Error: $e");
                  Future.delayed(const Duration(seconds: 5), connect);
                },
              );
        } else {
          print(
            "Doctor SSE: Failed to connect. Status: ${response.statusCode}. Retrying...",
          );
          Future.delayed(const Duration(seconds: 5), connect);
        }
      } catch (e) {
        print("Doctor SSE: Connection error: $e. Retrying...");
        Future.delayed(const Duration(seconds: 5), connect);
      }
    }

    connect();
    return controller.stream;
  }
}
