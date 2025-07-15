import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/ticket.dart';

class SseQueueRemoteDataSource {
  final _client = http.Client();
  final _tickets =
      <String, Ticket>{}; 

  Stream<List<Ticket>> getActiveTickets() {
    final controller = StreamController<List<Ticket>>();


    Future<void> connect() async {
      print("SSE: Connecting to http://localhost:8080/tickets");
      try {
        final request = http.Request(
          'GET',
          Uri.parse('http://localhost:8080/tickets'),
        );
        request.headers['Accept'] = 'text/event-stream';
        request.headers['Cache-Control'] = 'no-cache';

        final response = await _client.send(request);

        if (response.statusCode == 200) {
          print("SSE: Connected successfully.");
          _tickets.clear(); 

          response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .listen(
                (line) {
                  if (line.startsWith('event:')) {
                    final event = line.substring(6).trim();
                    _currentEvent = event;
                  } else if (line.startsWith('data:')) {
                    final data = line.substring(5).trim();
                    _processSseEvent(_currentEvent, data);
                    controller.add(_tickets.values.toList());
                  }
                },
                onDone: () {
                  print(
                    "SSE: Stream closed by server. Reconnecting in 5 seconds...",
                  );
                  Future.delayed(const Duration(seconds: 5), connect);
                },
                onError: (e, s) {
                  print(
                    "SSE: Error in stream. Reconnecting in 5 seconds... Error: $e",
                  );
                  controller.addError(e, s);
                  Future.delayed(const Duration(seconds: 5), connect);
                },
                cancelOnError: false,
              );
        } else {
          print(
            "SSE: Failed to connect. Status: ${response.statusCode}. Retrying in 5 seconds...",
          );
          Future.delayed(const Duration(seconds: 5), connect);
        }
      } catch (e) {
        print("SSE: Connection error: $e. Retrying in 5 seconds...");
        Future.delayed(const Duration(seconds: 5), connect);
      }
    }

    connect();

    return controller.stream;
  }

  String _currentEvent = '';

  void _processSseEvent(String event, String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;

      final ticket = Ticket.fromJson(json);

      print("SSE: Received event '$event' for ticket ${ticket.id}");

      if (ticket.status.isEmpty) {
        if (_tickets.containsKey(ticket.id)) {
          print(
            "SSE: Removing ticket ${ticket.id} due to non-displayable status.",
          );
          _tickets.remove(ticket.id);
        }
        return;
      }

      switch (event) {
        case 'insert':
        case 'update':
          _tickets[ticket.id] = ticket;
          break;
        case 'delete':
          _tickets.remove(ticket.id);
          break;
      }
    } catch (e) {
      print("SSE: Failed to process event data. Error: $e, Data: $data");
    }
  }
}
