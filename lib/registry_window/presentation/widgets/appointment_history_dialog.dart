import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/appointment_details_entity.dart';
import '../../domain/entities/patient_entity.dart';
import '../blocs/appointment/appointment_bloc.dart';

class AppointmentHistoryDialog extends StatefulWidget {
  final PatientEntity patient;

  const AppointmentHistoryDialog({super.key, required this.patient});

  @override
  State<AppointmentHistoryDialog> createState() => _AppointmentHistoryDialogState();
}

class _AppointmentHistoryDialogState extends State<AppointmentHistoryDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AppointmentBloc>().add(LoadPatientAppointments(widget.patient.id));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final past = state.patientAppointments.where((a) => !a.isFuture).toList();
        final upcoming = state.patientAppointments.where((a) => a.isFuture).toList();
        upcoming.sort((a, b) {
          final dateComparison = a.date.compareTo(b.date);
          if (dateComparison != 0) {
            return dateComparison;
          }
          return a.startTime.compareTo(b.startTime);
        });

        return AlertDialog(
          title: Text('История записей: ${widget.patient.fullName}'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            child: state.historyLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(text: 'Будущие (${upcoming.length})'),
                          Tab(text: 'Прошедшие (${past.length})'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAppointmentList(upcoming, isUpcoming: true),
                            _buildAppointmentList(past, isUpcoming: false),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentList(List<AppointmentDetailsEntity> appointments,
      {required bool isUpcoming}) {
    if (appointments.isEmpty) {
      return const Center(child: Text('Записей нет.'));
    }
    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat('dd.MM.yyyy').format(DateTime.parse(appointment.date))),
                Text(appointment.startTime.substring(0, 5), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            title: Text('Врач: ${appointment.doctorName} (Кабинет: ${appointment.cabinet ?? 'N/A'})'),
            subtitle: Text('Специализация: ${appointment.doctorSpec}'),
            trailing: isUpcoming
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Удалить',
                    onPressed: () => _confirmDelete(context, appointment.appointmentId),
                  )
                : (appointment.ticketNumber != null ? Chip(label: Text(appointment.ticketNumber!)) : const SizedBox.shrink()),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int appointmentId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Подтверждение'),
        content: const Text('Вы уверены, что хотите удалить эту запись? Слот в расписании будет освобожден.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AppointmentBloc>().add(DeleteAppointment(appointmentId));
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}