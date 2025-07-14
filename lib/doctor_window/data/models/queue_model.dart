import '../../domain/entities/queue_entity.dart';

class QueueModel extends QueueEntity {
  const QueueModel({
    required bool isAppointmentInProgress,
    required int queueLength,
    String? currentTicket,
  }) : super(
          isAppointmentInProgress: isAppointmentInProgress,
          queueLength: queueLength,
          currentTicket: currentTicket,
        );

  factory QueueModel.fromJson(Map<String, dynamic> json) {
    return QueueModel(
      isAppointmentInProgress: json['isAppointmentInProgress'] as bool,
      queueLength: json['queueLength'] as int,
      currentTicket: json['currentTicket'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAppointmentInProgress': isAppointmentInProgress,
      'queueLength': queueLength,
      'currentTicket': currentTicket,
    };
  }
}