import '../models/waiting_screen_model.dart';

abstract class WaitingScreenRemoteDataSource {
  Stream<WaitingScreenModel> getWaitingScreenData();
}