import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/entities/schedule_slot_entity.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<DoctorEntity>> getActiveDoctors();
  Future<List<ScheduleSlotEntity>> getDoctorSchedule(int doctorId, String date);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final http.Client client;
  final String _baseUrl = AppConfig.apiBaseUrl;

  ScheduleRemoteDataSourceImpl({http.Client? client}) : client = client ?? http.Client();

  @override
  Future<List<DoctorEntity>> getActiveDoctors() async {
    final response = await client.get(
      Uri.parse('$_baseUrl/api/doctor/active'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => DoctorEntity.fromJson(json)).toList();
    } else {
      throw Exception('Не удалось загрузить список врачей');
    }
  }

  @override
  Future<List<ScheduleSlotEntity>> getDoctorSchedule(int doctorId, String date) async {
    final uri = Uri.parse('$_baseUrl/api/doctor/schedule/$doctorId').replace(queryParameters: {'date': date});
    final response = await client.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => ScheduleSlotEntity.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}