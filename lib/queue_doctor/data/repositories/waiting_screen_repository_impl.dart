import '../../domain/repositories/waiting_screen_repository.dart';
import '../datasources/waiting_screen_remote_data_source.dart';
import '../models/waiting_screen_model.dart';

class WaitingScreenRepositoryImpl implements WaitingScreenRepository {
  final WaitingScreenRemoteDataSource remoteDataSource;

  WaitingScreenRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<WaitingScreenModel> getWaitingScreenData() {
    return remoteDataSource.getWaitingScreenData();
  }
}