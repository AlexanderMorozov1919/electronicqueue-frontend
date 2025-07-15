import 'package:dartz/dartz.dart';
import '../repositories/ticket_repository.dart';
import '../../core/errors/failures.dart';
import '../entities/ticket_entity.dart';

class GetCurrentTicket {
  final TicketRepository repository;

  GetCurrentTicket(this.repository);

  Future<Either<Failure, TicketEntity?>> call() async {
    return await repository.getCurrentTicket();
  }
}