import 'package:equatable/equatable.dart';
import '../../core/usecases/usecase.dart';
import '../entities/waiting_screen_entity.dart';
import '../repositories/waiting_screen_repository.dart';

class GetWaitingScreenData
    implements UseCase<WaitingScreenEntity, GetWaitingScreenDataParams> {
  final WaitingScreenRepository repository;

  GetWaitingScreenData(this.repository);

  @override
  Stream<WaitingScreenEntity> call(GetWaitingScreenDataParams params) {
    return repository.getWaitingScreenData(params);
  }
}

class GetWaitingScreenDataParams extends Equatable {
  final int cabinetNumber;

  const GetWaitingScreenDataParams({required this.cabinetNumber});

  @override
  List<Object?> get props => [cabinetNumber];
}