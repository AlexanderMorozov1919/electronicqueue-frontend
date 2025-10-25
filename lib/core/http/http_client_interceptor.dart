import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

// Универсальный интерфейс для сервисов токенов, чтобы перехватчик не зависел от конкретной реализации.
abstract class BaseAuthTokenService {
  String? get token;
  Future<void> clearToken();
}

class HttpClientInterceptor extends http.BaseClient {
  final http.Client _inner;
  final BaseAuthTokenService _tokenService;
  final VoidCallback _onUnauthorized;

  HttpClientInterceptor(this._inner, this._tokenService, this._onUnauthorized);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Добавляем токен авторизации ко всем запросам
    if (_tokenService.token != null) {
      request.headers['Authorization'] = 'Bearer ${_tokenService.token}';
    }

    final response = await _inner.send(request);

    // Проверяем статус ответа
    if (response.statusCode == 401) {
      // Если токен истек, вызываем callback для выхода из системы
      _onUnauthorized();

      // Чтобы избежать дальнейшей обработки запроса в приложении,
      // мы можем вернуть "пустой" ответ или бросить исключение.
      // В данном случае, мы предотвратим дальнейшую обработку, вернув ошибку.
      final newResponse = http.StreamedResponse(
        Stream.value(utf8.encode(json.encode({'error': 'Unauthorized'}))),
        401,
        headers: response.headers,
        reasonPhrase: 'Unauthorized',
      );
      return newResponse;
    }

    return response;
  }
}