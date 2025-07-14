import '../entities/waiting_screen_entity.dart';

abstract class WaitingScreenRepository {
  Stream<WaitingScreenEntity> getWaitingScreenData();
}