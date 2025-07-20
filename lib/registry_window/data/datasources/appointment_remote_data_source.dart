import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/entities/schedule_slot_entity.dart';
import '../services/auth_token_service.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<DoctorEntity>> getActiveDoctors();
  Future<List<ScheduleSlotEntity>> getDoctorSchedule(int doctorId, String date);
  Future<void> createAppointment({
    required int scheduleId,
    required int patientId,
    required int ticketId,
  });
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final http.Client client;
  final String _baseUrl = AppConfig.apiBaseUrl;
  final AuthTokenService _tokenService = AuthTokenService();

  AppointmentRemoteDataSourceImpl({required this.client});

  Map<String, String> _getAuthHeaders() {
    final token = _tokenService.token;
    if (token == null) throw ServerException('Пользователь не авторизован');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<DoctorEntity>> getActiveDoctors() async {
    final response = await client.get(
      Uri.parse('$_baseUrl/api/doctor/active'), 
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => DoctorEntity.fromJson(json)).toList();
    } else {
      throw ServerException('Не удалось загрузить список врачей');
    }
  }

  @override
  Future<List<ScheduleSlotEntity>> getDoctorSchedule(int doctorId, String date) async {
    final uri = Uri.parse('$_baseUrl/api/registrar/schedules/doctor/$doctorId').replace(queryParameters: {'date': date});
    final response = await client.get(uri, headers: _getAuthHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => ScheduleSlotEntity.fromJson(json)).toList();
    } else {
      throw ServerException('Не удалось загрузить расписание');
    }
  }
  
  @override
  Future<void> createAppointment({required int scheduleId, required int patientId, required int ticketId}) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/api/registrar/appointments'),
      headers: _getAuthHeaders(),
      body: json.encode({
        'schedule_id': scheduleId,
        'patient_id': patientId,
        'ticket_id': ticketId,
      }),
    );

    if (response.statusCode != 201) {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      throw ServerException(errorBody['error'] ?? 'Не удалось создать запись');
    }
  }
}