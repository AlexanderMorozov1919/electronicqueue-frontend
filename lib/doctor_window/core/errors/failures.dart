abstract class Failure {
  final String message;

  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure() : super('Ошибка сервера');
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure() : super('Некорректные данные');
}