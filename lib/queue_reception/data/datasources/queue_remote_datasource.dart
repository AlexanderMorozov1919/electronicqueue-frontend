import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/ticket.dart';

class SseQueueRemoteDataSource {
  final _client = http.Client();
  final _tickets = <String, Ticket>{};
  bool _isInitialFetchDone = false;

  Stream<List<Ticket>> getActiveTickets() {
    final controller = StreamController<List<Ticket>>();

    Future<void> connect() async {
      if (!_isInitialFetchDone) {
        await _fetchInitialTickets(controller);
        _isInitialFetchDone = true;
      }

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

          response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .listen(
                (line) {
                  if (line.startsWith('event:')) {
                    _currentEvent = line.substring(6).trim();
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

                  _isInitialFetchDone = false;
                  controller.addError(e, s);
                  Future.delayed(const Duration(seconds: 5), connect);
                },
                cancelOnError: false,
              );
        } else {
          print(
            "SSE: Failed to connect. Status: ${response.statusCode}. Retrying in 5 seconds...",
          );
          _isInitialFetchDone = false;
          Future.delayed(const Duration(seconds: 5), connect);
        }
      } catch (e) {
        print("SSE: Connection error: $e. Retrying in 5 seconds...");
        _isInitialFetchDone = false;
        Future.delayed(const Duration(seconds: 5), connect);
      }
    }

    connect();

    return controller.stream;
  }

  Future<void> _fetchInitialTickets(
    StreamController<List<Ticket>> controller,
  ) async {
    try {
      print("HTTP: Fetching initial active tickets...");
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/tickets/active'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        _tickets.clear();
        for (var item in data) {
          final ticket = Ticket.fromJson(item);
          if (ticket.status.isNotEmpty) {
            _tickets[ticket.id] = ticket;
          }
        }
        print("HTTP: Found ${_tickets.length} active tickets.");
        controller.add(_tickets.values.toList());
      } else {
        print(
          "HTTP: Failed to fetch initial tickets. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("HTTP: Error fetching initial tickets: $e");
    }
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
