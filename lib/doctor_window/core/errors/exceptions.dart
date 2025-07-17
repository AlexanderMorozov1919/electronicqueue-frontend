class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class EmptyQueueException implements Exception {}
