import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null) {
      throw Exception('API_BASE_URL не найден в .env файле');
    }
    return url;
  }

  static String get externalApiKey {
    final key = dotenv.env['EXTERNAL_API_KEY'];
    if (key == null) {
      throw Exception('EXTERNAL_API_KEY не найден в .env файле');
    }
    return key;
  }
}