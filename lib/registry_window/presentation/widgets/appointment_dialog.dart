import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/doctor_entity.dart';
import '../blocs/appointment/appointment_bloc.dart';
import 'patient_search_field.dart';

class AppointmentDialog extends StatefulWidget {
  final String ticketId;

  const AppointmentDialog({super.key, required this.ticketId});

  @override
  State<AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<AppointmentDialog> {
  int? _selectedSlotId;
  final TextEditingController _patientController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AppointmentBloc>().add(LoadAppointmentInitialData());
  }
  
  @override
  void dispose() {
    _patientController.dispose();
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
        if (state.submissionSuccess) {
           Navigator.of(context).pop(true);
        }
        // Обновляем контроллер, если BLoC выбрал/создал пациента
        if (state.selectedPatient != null && _patientController.text != state.selectedPatient!.fullName) {
          _patientController.text = state.selectedPatient!.fullName;
        } else if (state.selectedPatient == null) {
           _patientController.clear();
        }
      },
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Запись пациента к врачу'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.75,
            child: _buildForm(context, state),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: (state.selectedPatient != null && _selectedSlotId != null && !state.isLoading)
                  ? () {
                      context.read<AppointmentBloc>().add(SubmitAppointment(
                        scheduleId: _selectedSlotId!,
                        ticketId: int.parse(widget.ticketId),
                      ));
                    }
                  : null,
              child: const Text('Записать'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, AppointmentState state) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildPatientSelector(context, state)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildDoctorSelector(context, state)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildSpecialtyField(state)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildDateSelector(context, state)),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        Expanded(child: _buildScheduler(context, state)),
      ],
    );
  }
  
  Widget _buildPatientSelector(BuildContext context, AppointmentState state) {
    final bloc = context.read<AppointmentBloc>();
    return PatientSearchField(
      controller: _patientController,
      onPatientSelected: (patient) {
        bloc.add(SelectPatient(patient));
      },
      onPatientCleared: () {
        bloc.add(const SelectPatient(null));
      },
    );
  }

   Widget _buildDoctorSelector(BuildContext context, AppointmentState state) {
    return DropdownButtonFormField<DoctorEntity?>(
      decoration: const InputDecoration(labelText: 'Врач', border: OutlineInputBorder()),
      value: state.selectedDoctor,
      isExpanded: true,
      items: [
        const DropdownMenuItem<DoctorEntity?>(
          value: null,
          child: Text('Не выбрано', style: TextStyle(color: Colors.grey)),
        ),
        ...state.doctors.map((doctor) {
          return DropdownMenuItem<DoctorEntity>(
            value: doctor,
            child: Tooltip(
              message: doctor.fullName,
              child: Text(
                doctor.fullName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }),
      ],
      onChanged: (doctor) {
        context.read<AppointmentBloc>().add(AppointmentDoctorSelected(doctor));
        setState(() { _selectedSlotId = null; });
      },
    );
  }

  Widget _buildSpecialtyField(AppointmentState state) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Специализация',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      controller: TextEditingController(text: state.selectedDoctor?.specialization ?? ''),
    );
  }

  Widget _buildDateSelector(BuildContext context, AppointmentState state) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: state.selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (picked != null && picked != state.selectedDate) {
          context.read<AppointmentBloc>().add(AppointmentDateChanged(picked));
          setState(() { _selectedSlotId = null; });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Дата', border: OutlineInputBorder()),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd.MM.yyyy').format(state.selectedDate)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduler(BuildContext context, AppointmentState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.selectedDoctor == null) {
      return const Center(child: Text('Выберите врача для отображения расписания.'));
    }
    if (state.schedule.isEmpty) {
      return const Center(child: Text('Нет доступных слотов на выбранную дату.'));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3,
      ),
      itemCount: state.schedule.length,
      itemBuilder: (context, index) {
        final slot = state.schedule[index];
        final isSelected = slot.id == _selectedSlotId;

        return Tooltip(
          message: slot.isAvailable ? "Свободно" : "Занято: ${slot.patientName ?? 'н/д'}",
          child: ChoiceChip(
            label: Text(DateFormat('HH:mm').format(slot.startTime)),
            selected: isSelected,
            selectedColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black),
            backgroundColor: slot.isAvailable ? Colors.green.shade100 : Colors.red.shade100,
            onSelected: slot.isAvailable
                ? (selected) {
                    setState(() { _selectedSlotId = selected ? slot.id : null; });
                  }
                : null,
          ),
        );
      },
    );
  }
}