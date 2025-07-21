import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/ticket_repository.dart';
import '../entities/ticket_entity.dart';
import '../../core/utils/ticket_category.dart';

class GetTicketsByCategory {
  final TicketRepository repository;

  GetTicketsByCategory(this.repository);

  Future<Either<Failure, List<TicketEntity>>> call(TicketCategory category) async {
    return await repository.getTicketsByCategory(category);
  }
}