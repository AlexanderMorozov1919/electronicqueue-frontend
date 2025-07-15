import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/waiting_screen_model.dart';

abstract class WaitingScreenRemoteDataSource {
  Stream<WaitingScreenModel> getWaitingScreenData();
}

class WaitingScreenRemoteDataSourceImpl implements WaitingScreenRemoteDataSource {
  final http.Client _client;
  String _currentEvent = '';

  WaitingScreenRemoteDataSourceImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Stream<WaitingScreenModel> getWaitingScreenData() {
    final controller = StreamController<WaitingScreenModel>();

    Future<void> connect() async {
      try {
        final request = http.Request(
          'GET',
          Uri.parse('http://localhost:8080/api/doctor/screen-updates'),
        );
        request.headers['Accept'] = 'text/event-stream';
        request.headers['Cache-Control'] = 'no-cache';

        final response = await _client.send(request);

        if (response.statusCode == 200) {

          response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .listen(
                (line) {
                  if (line.startsWith('event:')) {
                    _currentEvent = line.substring(6).trim();
                  } else if (line.startsWith('data:')) {
                    final data = line.substring(5).trim();
                    if (_currentEvent == 'state_update' || _currentEvent == 'error') {
                      try {
                        final json = jsonDecode(data);
                        if (json['error'] != null) {
                           controller.addError(Exception(json['error']));
                        } else {
                           final model = WaitingScreenModel.fromJson(json);
                           controller.add(model);
                        }
                      } catch (e) {
                         print("SSE Doctor: Failed to parse data. Error: $e, Data: $data");
                      }
                    }
                  }
                },
                onDone: () {
                  Future.delayed(const Duration(seconds: 5), connect);
                },
                onError: (e, s) {
                  controller.addError(e, s);
                  Future.delayed(const Duration(seconds: 5), connect);
                },
                cancelOnError: false,
              );
        } else {
          Future.delayed(const Duration(seconds: 5), connect);
        }
      } catch (e) {
        Future.delayed(const Duration(seconds: 5), connect);
      }
    }

    connect();
    return controller.stream;
  }
}