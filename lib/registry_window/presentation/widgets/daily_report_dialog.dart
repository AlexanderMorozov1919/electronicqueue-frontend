import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/report/report_bloc.dart';

class DailyReportDialog extends StatefulWidget {
  const DailyReportDialog({super.key});

  @override
  State<DailyReportDialog> createState() => _DailyReportDialogState();
}

class _DailyReportDialogState extends State<DailyReportDialog> {
  String? _selectedDoctor;
  String? _selectedStatus;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // 1. Declare ScrollControllers
  late final ScrollController _verticalScrollController;
  late final ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(LoadDailyReport());

    // 2. Initialize ScrollControllers
    _verticalScrollController = ScrollController();
    _horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    // 3. Dispose of ScrollControllers
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<ReportBloc>().add(FilterReport(
          doctorFilter: _selectedDoctor,
          statusFilter: _selectedStatus,
          startTimeFilter: _startTime,
          endTimeFilter: _endTime,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF1F3F4),
          title: Row(
            children: [
              const Text('Отчет по талонам за сегодня'),
              const Spacer(),
              if (state.isLoading) const CircularProgressIndicator(),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                _buildFilters(context, state),
                const SizedBox(height: 16),
                Expanded(child: _buildDataTable(context, state)),
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

  Widget _buildFilters(BuildContext context, ReportState state) {
    final doctors =
        state.allRows.map((e) => e.doctorFullName).whereType<String>().toSet().toList();
    doctors.insert(0, 'Все');

    final statuses =
        state.allRows.map((e) => e.status).toSet().toList();
    statuses.insert(0, 'Все');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              // Фильтр по врачу
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Врач', border: OutlineInputBorder()),
                  value: _selectedDoctor ?? 'Все',
                  items: doctors
                      .map((doc) => DropdownMenuItem(value: doc, child: Text(doc)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedDoctor = value);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 20),
              // Фильтр по статусу
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Статус', border: OutlineInputBorder()),
                  value: _selectedStatus ?? 'Все',
                  items: statuses
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Новая строка для фильтров по времени
          Row(
            children: [
              Expanded(child: _buildTimePicker(
                context: context,
                label: 'Время С',
                selectedTime: _startTime,
                onTimeSelected: (time) {
                  setState(() => _startTime = time);
                  _applyFilters();
                }
              )),
              const SizedBox(width: 20),
              Expanded(child: _buildTimePicker(
                context: context,
                label: 'Время ПО',
                selectedTime: _endTime,
                onTimeSelected: (time) {
                  setState(() => _endTime = time);
                  _applyFilters();
                }
              )),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required BuildContext context,
    required String label,
    required TimeOfDay? selectedTime,
    required ValueChanged<TimeOfDay?> onTimeSelected,
  }) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (time != null) {
          onTimeSelected(time);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: selectedTime != null 
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => onTimeSelected(null),
              )
            : null,
        ),
        child: Text(selectedTime?.format(context) ?? 'Не выбрано'),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, ReportState state) {
    if (state.error != null) {
      return Center(child: Text('Ошибка: ${state.error}'));
    }
    if (state.displayedRows.isEmpty && !state.isLoading) {
      return const Center(child: Text('Нет данных для отображения.'));
    }

    // 4. Assign the controllers to the widgets
    return Scrollbar(
      thumbVisibility: true,
      controller: _verticalScrollController, // Assign vertical controller
      child: SingleChildScrollView(
        controller: _verticalScrollController, // Assign vertical controller
        scrollDirection: Axis.vertical,
        child: Scrollbar(
          thumbVisibility: true,
          controller: _horizontalScrollController, // Assign horizontal controller
          child: SingleChildScrollView(
            controller: _horizontalScrollController, // Assign horizontal controller
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: state.sortColumnIndex,
              sortAscending: state.isAscending,
              columns: [
                DataColumn(label: const Text('Номер талона'), onSort: (i, a) => _onSort(context, i, a)),
                DataColumn(label: const Text('ФИО пациента'), onSort: (i, a) => _onSort(context, i, a)),
                DataColumn(label: const Text('ФИО врача'), onSort: (i, a) => _onSort(context, i, a)),
                DataColumn(label: const Text('Специализация'), onSort: (i, a) => _onSort(context, i, a)),
                DataColumn(label: const Text('Кабинет'), onSort: (i, a) => _onSort(context, i, a)),
                DataColumn(label: const Text('Время приема'), onSort: (i, a) => _onSort(context, i, a)),
                DataColumn(label: const Text('Статус'), onSort: (i, a) => _onSort(context, i, a)),
              ],
              rows: state.displayedRows.map((row) {
                return DataRow(cells: [
                  DataCell(Text(row.ticketNumber)),
                  DataCell(Text(row.patientFullName ?? '–')),
                  DataCell(Text(row.doctorFullName ?? '–')),
                  DataCell(Text(row.doctorSpecialization ?? '–')),
                  DataCell(Text(row.cabinetNumber?.toString() ?? '–')),
                  DataCell(Text(row.appointmentTime ?? '–')),
                  DataCell(Text(row.status)),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _onSort(BuildContext context, int columnIndex, bool ascending) {
    context.read<ReportBloc>().add(SortReport(columnIndex: columnIndex, ascending: ascending));
  }
}