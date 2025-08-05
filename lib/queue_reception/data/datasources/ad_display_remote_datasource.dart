import 'dart:convert';
import 'package:elqueue/config/app_config.dart';
import 'package:elqueue/queue_reception/domain/entities/ad_display.dart';
import 'package:http/http.dart' as http;

class AdDisplayRemoteDataSource {
  final http.Client client;

  AdDisplayRemoteDataSource({required this.client});

  Future<List<AdDisplay>> getEnabledAds(String screen) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/ads/enabled?screen=$screen');

    final response = await client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => AdDisplay.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load ads for screen: $screen');
    }
  }
}