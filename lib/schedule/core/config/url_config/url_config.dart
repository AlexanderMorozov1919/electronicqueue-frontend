class Urls {
  final String apiGateAwayUrl;

  Urls({
    required this.apiGateAwayUrl,
  });
}

class UrlConfig {
  static Urls get main => Urls(apiGateAwayUrl: '192.168.29.137:5000');
}
