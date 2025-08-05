import 'dart:convert';
import 'package:elqueue/config/app_config.dart';
import 'package:elqueue/queue_reception/domain/entities/ad_display.dart';
import 'package:http/http.dart' as http;

class AdDisplayRemoteDataSource {
  final http.Client client;

  AdDisplayRemoteDataSource({required this.client});

  Future<List<AdDisplay>> getEnabledAds() async {
    final response = await client.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/ads/enabled'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => AdDisplay.fromJson(json)).toList();
    } else {
      print('Failed to load ads: ${response.statusCode}');
      return [];
    }
  }
}