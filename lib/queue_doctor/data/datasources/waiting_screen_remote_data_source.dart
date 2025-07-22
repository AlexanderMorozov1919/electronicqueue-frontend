import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../models/waiting_screen_model.dart';

abstract class WaitingScreenRemoteDataSource {
  Stream<DoctorQueueModel> getWaitingScreenData(int cabinetNumber);
  Future<List<int>> getActiveCabinets();
}

class WaitingScreenRemoteDataSourceImpl
    implements WaitingScreenRemoteDataSource {
  final http.Client _client;
  String _currentEvent = '';

  WaitingScreenRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<int>> getActiveCabinets() async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/doctor/cabinets/active'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.cast<int>().toList();
    } else {
      throw Exception('Не удалось загрузить список кабинетов: ${response.statusCode}');
    }
  }

  @override
  Stream<DoctorQueueModel> getWaitingScreenData(int cabinetNumber) {
    final controller = StreamController<DoctorQueueModel>();

    Future<void> connect() async {
      try {
        final request = http.Request(
          'GET',
          Uri.parse(
              '${AppConfig.apiBaseUrl}/api/doctor/screen-updates/$cabinetNumber'),
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
                if (_currentEvent == 'state_update') {
                  try {
                    final json = jsonDecode(data);
                    final model = DoctorQueueModel.fromJson(json);
                    controller.add(model);
                  } catch (e) {
                    print(
                        "SSE Doctor: Failed to parse data. Error: $e, Data: $data");
                    controller.addError(Exception("Ошибка парсинга данных от сервера."));
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