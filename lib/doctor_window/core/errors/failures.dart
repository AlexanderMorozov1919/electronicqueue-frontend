abstract class Failure {
  final String message;
  const Failure({required this.message});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure() : super(message: 'Некорректные данные');
}

class EmptyQueueFailure extends Failure {
  EmptyQueueFailure() : super(message: 'В очереди нет пациентов');
}
