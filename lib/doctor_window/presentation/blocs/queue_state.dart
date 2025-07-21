import 'package:equatable/equatable.dart';
import '../../domain/entities/queue_entity.dart';

abstract class QueueState extends Equatable {
  const QueueState();

  @override
  List<Object?> get props => [];
}

class QueueInitial extends QueueState {}

class QueueLoading extends QueueState {}

class QueueLoaded extends QueueState {
  final QueueEntity queue;
  final String? infoMessage;

  const QueueLoaded({required this.queue, this.infoMessage});

  @override
  List<Object?> get props => [queue, infoMessage];
}

class QueueError extends QueueState {
  final String message;

  const QueueError({required this.message});

  @override
  List<Object> get props => [message];
}