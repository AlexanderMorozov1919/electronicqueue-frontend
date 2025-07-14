abstract class UseCase<Type, Params> {
  Stream<Type> call(Params params);
}

class NoParams {
  const NoParams();
}