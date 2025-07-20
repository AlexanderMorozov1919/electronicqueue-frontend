import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_token_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final http.Client client;
  final AuthTokenService tokenService;

  AuthRepositoryImpl({http.Client? client})
    : client = client ?? http.Client(),
      tokenService = AuthTokenService();

  @override
  Future<Either<Failure, bool>> authenticate(AuthEntity authEntity) async {
    try {
      final response = await client.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/auth/login/registrar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'login': authEntity.login,
          'password': authEntity.password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final token = data['token'] as String?;
        if (token != null) {
          tokenService.setToken(token);
          return const Right(true);
        }
        return Left(ServerFailure('Сервер не вернул токен'));
      } else {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Left(ServerFailure(data['error'] ?? 'Ошибка аутентификации'));
      }
    } catch (e) {
      return Left(ServerFailure('Не удалось подключиться к серверу'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    tokenService.clearToken();
    return const Right(null);
  }
}
