import '../../domain/repositories/waiting_screen_repository.dart';
import '../../domain/usecases/get_waiting_screen_data.dart';
import '../datasources/waiting_screen_remote_data_source.dart';
import '../models/waiting_screen_model.dart';

class WaitingScreenRepositoryImpl implements WaitingScreenRepository {
  final WaitingScreenRemoteDataSource remoteDataSource;

  WaitingScreenRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<WaitingScreenModel> getWaitingScreenData(
      GetWaitingScreenDataParams params) {
    return remoteDataSource.getWaitingScreenData(params.cabinetNumber);
  }

  @override
  Future<List<int>> getActiveCabinets() {
    return remoteDataSource.getActiveCabinets();
  }
}