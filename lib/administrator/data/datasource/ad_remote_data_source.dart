import 'dart:convert';
import 'package:elqueue/config/app_config.dart';
import 'package:http/http.dart' as http;
import '../../../administrator/core/errors/exceptions.dart';
import '../../../administrator/domain/entities/ad_entity.dart';

abstract class AdRemoteDataSource {
  Future<List<AdEntity>> getAds();
  Future<AdEntity> getAdById(int id); // ИСПРАВЛЕНИЕ: Добавляем метод
  Future<AdEntity> createAd(AdEntity ad);
  Future<AdEntity> updateAd(AdEntity ad);
  Future<void> deleteAd(int id);
}

class AdRemoteDataSourceImpl implements AdRemoteDataSource {
  final http.Client client;

  AdRemoteDataSourceImpl({required this.client});

  @override
  Future<List<AdEntity>> getAds() async {
    final response = await client.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/admin/ads'),
      headers: {'X-API-KEY': AppConfig.internalApiKey},
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      if (responseBody.isEmpty || responseBody == 'null') {
        return [];
      }
      final dynamic decodedJson = json.decode(responseBody);
      if (decodedJson is! List) {
        throw ServerException('Неожиданный формат ответа от сервера');
      }
      return decodedJson.map((json) => AdEntity.fromJson(json)).toList();
    } else {
      throw ServerException('Не удалось загрузить список рекламы');
    }
  }

  // ИСПРАВЛЕНИЕ: Реализуем метод для получения одной рекламы с картинкой
  @override
  Future<AdEntity> getAdById(int id) async {
    final response = await client.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/admin/ads/$id'),
      headers: {'X-API-KEY': AppConfig.internalApiKey},
    );
    if (response.statusCode == 200) {
      return AdEntity.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw ServerException('Не удалось загрузить данные для рекламы ID $id');
    }
  }


  @override
  Future<AdEntity> createAd(AdEntity ad) async {
    final response = await client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/admin/ads'),
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': AppConfig.internalApiKey,
      },
      body: json.encode(ad.toJsonForCreate()),
    );

    if (response.statusCode == 201) {
      return AdEntity.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw ServerException('Не удалось создать рекламу');
    }
  }

  @override
  Future<AdEntity> updateAd(AdEntity ad) async {
    final response = await client.patch(
      Uri.parse('${AppConfig.apiBaseUrl}/api/admin/ads/${ad.id}'),
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': AppConfig.internalApiKey,
      },
      body: json.encode(ad.toJsonForUpdate()),
    );

    if (response.statusCode == 200) {
      return AdEntity.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw ServerException('Не удалось обновить рекламу');
    }
  }

  @override
  Future<void> deleteAd(int id) async {
    final response = await client.delete(
      Uri.parse('${AppConfig.apiBaseUrl}/api/admin/ads/$id'),
      headers: {'X-API-KEY': AppConfig.internalApiKey},
    );

    if (response.statusCode != 200) {
      throw ServerException('Не удалось удалить рекламу');
    }
  }
}