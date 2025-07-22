import '../../domain/entities/waiting_screen_entity.dart';
import '../../domain/repositories/waiting_screen_repository.dart';
import '../../domain/usecases/get_waiting_screen_data.dart';
import '../datasources/waiting_screen_remote_data_source.dart';

class WaitingScreenRepositoryImpl implements WaitingScreenRepository {
  final WaitingScreenRemoteDataSource remoteDataSource;

  WaitingScreenRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<DoctorQueueEntity> getWaitingScreenData(
      GetWaitingScreenDataParams params) {
    // DataSource возвращает модель, которая является подтипом сущности,
    // поэтому прямое возвращение допустимо.
    return remoteDataSource.getWaitingScreenData(params.cabinetNumber);
  }

  @override
  Future<List<int>> getActiveCabinets() {
    return remoteDataSource.getActiveCabinets();
  }
}