import '../entities/waiting_screen_entity.dart';
import '../usecases/get_waiting_screen_data.dart';

abstract class WaitingScreenRepository {
  Stream<WaitingScreenEntity> getWaitingScreenData(
      GetWaitingScreenDataParams params);
  Future<List<int>> getActiveCabinets();
}