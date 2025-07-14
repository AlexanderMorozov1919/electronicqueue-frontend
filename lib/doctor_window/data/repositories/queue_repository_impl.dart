import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/queue_entity.dart';
import '../../domain/repositories/queue_repository.dart';
import '../datasourcers/queue_data_source.dart';

class QueueRepositoryImpl implements QueueRepository {
  final QueueDataSource dataSource;

  QueueRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, QueueEntity>> getQueueStatus() async {
    try {
      final result = await dataSource.getQueueStatus();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, QueueEntity>> endAppointment() async {
    try {
      final result = await dataSource.endAppointment();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, QueueEntity>> startAppointment(String ticket) async {
    try {
      final result = await dataSource.startAppointment(ticket);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}