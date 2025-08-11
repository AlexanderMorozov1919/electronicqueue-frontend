import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/ticket_repository.dart';
import '../entities/ticket_entity.dart';

class CallNextTicket {
  final TicketRepository repository;

  CallNextTicket(this.repository);

  Future<Either<Failure, TicketEntity>> call({
    required int windowNumber,
    String? categoryPrefix,
  }) async {
    return await repository.callNextTicket(windowNumber, categoryPrefix);
  }
}