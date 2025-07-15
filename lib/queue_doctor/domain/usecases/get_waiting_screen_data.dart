import '../entities/waiting_screen_entity.dart';
import '../repositories/waiting_screen_repository.dart';
import '../../core/usecases/usecase.dart';

class GetWaitingScreenData implements UseCase<WaitingScreenEntity, NoParams> {
  final WaitingScreenRepository repository;

  GetWaitingScreenData(this.repository);

  @override
  Stream<WaitingScreenEntity> call(NoParams params) {
    return repository.getWaitingScreenData();
  }
}