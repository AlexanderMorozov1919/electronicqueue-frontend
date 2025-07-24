import 'dart:async';
import 'dart:convert';
import 'package:elqueue/config/app_config.dart';
import 'package:http/http.dart' as http;
import '../models/today_schedule_model.dart';

abstract class ScheduleRemoteDataSource {
  Stream<dynamic> getScheduleUpdates();
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final http.Client _client;

  ScheduleRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Stream<dynamic> getScheduleUpdates() {
    final controller = StreamController<dynamic>();
    String currentEvent = '';

    void connect() async {
      try {
        final request = http.Request('GET',
            Uri.parse('${AppConfig.apiBaseUrl}/api/schedules/today/updates'));
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
                currentEvent = line.substring(6).trim();
              } else if (line.startsWith('data:')) {
                final data = line.substring(5).trim();
                try {
                  final json = jsonDecode(data);
                  if (currentEvent == 'schedule_initial') {
                    controller.add(TodayScheduleModel.fromJson(json));
                  } else if (currentEvent == 'schedule_update') {
                    controller.add(ScheduleUpdateDataModel.fromJson(json));
                  }
                } catch (e) {
                  print("SSE Schedule: Failed to parse data. Error: $e, Data: $data");
                  controller.addError(Exception("Ошибка парсинга данных от сервера."));
                }
              }
            },
            onDone: () {
              print('SSE Schedule: Stream closed. Reconnecting...');
              Future.delayed(const Duration(seconds: 5), connect);
            },
            onError: (e, s) {
              print('SSE Schedule: Error on stream. Reconnecting...');
              controller.addError(e, s);
              Future.delayed(const Duration(seconds: 5), connect);
            },
            cancelOnError: false,
          );
        } else {
          final body = await response.stream.bytesToString();
          controller.addError(Exception('Ошибка сервера (${response.statusCode}): $body'));
          Future.delayed(const Duration(seconds: 5), connect);
        }
      } catch (e) {
        controller.addError(e);
        Future.delayed(const Duration(seconds: 5), connect);
      }
    }

    connect();
    return controller.stream;
  }
}