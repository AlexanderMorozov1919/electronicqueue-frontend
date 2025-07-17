import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/queue_entity.dart';
import '../../domain/repositories/queue_repository.dart';
import '../datasourcers/queue_data_source.dart';
import '../../core/errors/exceptions.dart';

class QueueRepositoryImpl implements QueueRepository {
  final QueueDataSource dataSource;

  QueueRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, QueueEntity>> getQueueStatus() async {
    try {
      final result = await dataSource.getQueueStatus();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Неизвестная ошибка сервера'));
    }
  }

  @override
  Future<Either<Failure, QueueEntity>> endAppointment() async {
    try {
      final result = await dataSource.endAppointment();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Неизвестная ошибка сервера'));
    }
  }


  @override
  Future<Either<Failure, QueueEntity>> startAppointment(String ticket) async {
    try {
      final result = await dataSource.startAppointment(ticket);
      return Right(result);
    } on EmptyQueueException {
      return Left(EmptyQueueFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch(e) {
       return Left(ServerFailure(message: 'Неизвестная ошибка при вызове пациента'));
    }
  }


  @override
  Stream<Either<Failure, void>> ticketUpdates() {
    return dataSource.ticketUpdates().map((_) => const Right(null));
  }
}