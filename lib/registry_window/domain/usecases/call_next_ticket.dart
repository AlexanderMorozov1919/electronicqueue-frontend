import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/ticket_repository.dart';
import '../entities/ticket_entity.dart';

class CallNextTicket {
  final TicketRepository repository;

  final int windowNumber = 1;

  CallNextTicket(this.repository);

  Future<Either<Failure, TicketEntity>> call() async {
    return await repository.callNextTicket(windowNumber);
  }
}