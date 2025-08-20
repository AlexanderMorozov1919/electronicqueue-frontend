import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constans.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/repositories/patient_repository.dart';
import '../blocs/appointment/appointment_bloc.dart';
import '../blocs/ticket/ticket_state.dart';
import '../blocs/ticket/ticket_event.dart';
import '../blocs/ticket/ticket_bloc.dart';
import '../../domain/entities/ticket_entity.dart';
import 'appointment_dialog.dart';

class CurrentTicketSection extends StatefulWidget {
  const CurrentTicketSection({super.key});

  @override
  State<CurrentTicketSection> createState() => _CurrentTicketSectionState();
}

class _CurrentTicketSectionState extends State<CurrentTicketSection> {
  Timer? _timer;
  Duration _duration = Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(DateTime startTime) {
    _timer?.cancel();
    _duration = DateTime.now().difference(startTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _duration = DateTime.now().difference(startTime);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatDuration(Duration duration) {
    // Handle negative duration case by showing 00:00
    if (duration.isNegative) {
      return '00:00';
    }
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TicketBloc, TicketState>(
      listener: (context, state) {
        final ticket = state.currentTicket;
        // The timer should run as long as the ticket is not completed.
        if (ticket != null && ticket.calledAt != null && !ticket.isCompleted) {
          _startTimer(ticket.calledAt!);
        } else {
          _stopTimer();
        }
      },
      child: BlocSelector<TicketBloc, TicketState, (TicketEntity?, Type, bool)>(
        selector: (state) {
          return (state.currentTicket, state.runtimeType, state.isAppointmentButtonEnabled);
        },
        builder: (context, data) {
          final currentTicket = data.$1;
          final runtimeType = data.$2;
          final isAppointmentButtonEnabled = data.$3;
          final bool isAnyLoading = runtimeType == TicketLoading;
          return _buildTicketState(context, currentTicket, isAnyLoading, isAppointmentButtonEnabled);
        },
      ),
    );
  }

  Widget _buildTicketState(BuildContext context, TicketEntity? currentTicket, bool isAnyLoading, bool isAppointmentButtonEnabled) {
    final bool isTicketActiveForButtons = currentTicket != null && !currentTicket.isCompleted;

    Duration finalDuration;
    if (currentTicket?.completedAt != null && currentTicket?.calledAt != null) {
      finalDuration = currentTicket!.completedAt!.difference(currentTicket.calledAt!);
    } else {
      finalDuration = _duration;
    }

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppConstants.currentTicketLabel,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (currentTicket?.calledAt != null)
                  Chip(
                    avatar: Icon(Icons.timer_outlined, size: 20, color: currentTicket?.isCompleted ?? false ? Colors.grey : Colors.black),
                    label: Text(
                      _formatDuration(finalDuration),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: currentTicket?.isCompleted ?? false ? Colors.grey : Colors.black,
                      ),
                    ),
                    backgroundColor: currentTicket?.isCompleted ?? false ? Colors.grey.shade300 : Colors.blue.shade100,
                  )
              ],
            ),
            const SizedBox(height: 10),
            if (currentTicket != null)
              _buildActiveTicket(context, currentTicket, isTicketActiveForButtons, isAnyLoading, isAppointmentButtonEnabled)
            else
              const Text('Нет активного талона. Нажмите "Вызвать следующего".'),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTicket(BuildContext context, TicketEntity ticket, bool isActive, bool isAnyLoading, bool isAppointmentButtonEnabled) {
    final canRegister = isActive && !ticket.isRegistered;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ticket.number,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ticket.isCompleted ? Colors.grey : Colors.black,
              ),
            ),
            Text(
              'Категория: ${ticket.category.name}',
              style: TextStyle(color: ticket.isCompleted ? Colors.grey : Colors.black54),
            ),
            if (ticket.calledAt != null)
              Text(
                'Вызван в: ${DateFormat('HH:mm:ss').format(ticket.calledAt!)}',
                style: TextStyle(color: ticket.isCompleted ? Colors.grey : Colors.black54, fontSize: 12),
              ),
            if (ticket.completedAt != null)
              Text(
                'Завершён в: ${DateFormat('HH:mm:ss').format(ticket.completedAt!)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              )
          ],
        ),
        Row(
          children: [
            if (isAppointmentButtonEnabled) ...[
              _buildRegisterButton(context, ticket, canRegister, isAnyLoading),
              const SizedBox(width: 10),
            ],
            _buildCompleteButton(context, ticket, isActive, isAnyLoading),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context, TicketEntity ticket, bool canRegister, bool isAnyLoading) {
    return ElevatedButton(
      onPressed: canRegister && !isAnyLoading
          ? () {
              showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => AppointmentBloc(
                        appointmentRepository: context.read<AppointmentRepository>(),
                        patientRepository: context.read<PatientRepository>(),
                      )..add(const LoadAppointmentInitialData()),
                    ),
                    BlocProvider.value(
                      value: BlocProvider.of<TicketBloc>(context),
                    ),
                  ],
                  child: AppointmentDialog(ticketId: ticket.id),
                ),
              ).then((isSuccess) {
                if (isSuccess == true) {
                  context.read<TicketBloc>().add(RegisterCurrentTicketEvent());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Пациент успешно оформлен!'), backgroundColor: Colors.green),
                  );
                }
              });
            }
          : null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(150, 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        backgroundColor: const Color(0xFF4EB8A6),
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text("Оформить"),
    );
  }

  Widget _buildCompleteButton(BuildContext context, TicketEntity ticket, bool canComplete, bool isAnyLoading) {
    return ElevatedButton(
      onPressed: canComplete && !isAnyLoading
          ? () {
              context.read<TicketBloc>().add(CompleteCurrentTicketEvent());
            }
          : null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(150, 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        backgroundColor: const Color(0xFFFFA100),
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(AppConstants.completeButton),
    );
  }
}