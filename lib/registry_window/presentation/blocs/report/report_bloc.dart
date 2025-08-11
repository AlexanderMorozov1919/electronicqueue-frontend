import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // ИМПОРТ ДЛЯ TimeOfDay
import '../../../domain/entities/daily_report_row_entity.dart';
import '../../../domain/repositories/ticket_repository.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final TicketRepository ticketRepository;

  ReportBloc({required this.ticketRepository}) : super(const ReportState()) {
    on<LoadDailyReport>(_onLoadDailyReport);
    on<SortReport>(_onSortReport);
    on<FilterReport>(_onFilterReport);
  }

  Future<void> _onLoadDailyReport(
      LoadDailyReport event, Emitter<ReportState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await ticketRepository.getDailyReport();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (rows) {
        emit(state.copyWith(
          isLoading: false,
          allRows: rows,
          displayedRows: rows,
          clearFilters: true,
        ));
      },
    );
  }
  
  (String, int) _parseTicketNumber(String ticketNumber) {
    final letterPart = ticketNumber.replaceAll(RegExp(r'[0-9]'), '');
    final numberPart = ticketNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return (letterPart, int.tryParse(numberPart) ?? 0);
  }

  void _onSortReport(SortReport event, Emitter<ReportState> emit) {
    if (state.displayedRows.isEmpty) return;

    final newSortColumnIndex = event.columnIndex;
    final newIsAscending = state.sortColumnIndex == newSortColumnIndex
        ? !state.isAscending
        : true;

    final sortedRows = List<DailyReportRowEntity>.from(state.displayedRows);

    TimeOfDay? _parseTime(String? timeString) {
      if (timeString == null) return null;
      try {
        final parts = timeString.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (e) {
        return null;
      }
    }

    sortedRows.sort((a, b) {
      int comparison;
      switch (newSortColumnIndex) {
        case 0: // Ticket Number
          final aParsed = _parseTicketNumber(a.ticketNumber);
          final bParsed = _parseTicketNumber(b.ticketNumber);
          comparison = aParsed.$1.compareTo(bParsed.$1); 
          if (comparison == 0) {
            comparison = aParsed.$2.compareTo(bParsed.$2);
          }
          break;
        case 1: // Patient
          comparison = (a.patientFullName ?? '').compareTo(b.patientFullName ?? '');
          break;
        case 2: // Doctor
          comparison = (a.doctorFullName ?? '').compareTo(b.doctorFullName ?? '');
          break;
        case 3: // Specialization
          comparison = (a.doctorSpecialization ?? '').compareTo(b.doctorSpecialization ?? '');
          break;
        case 4: // Cabinet (как число)
          comparison = (a.cabinetNumber ?? 0).compareTo(b.cabinetNumber ?? 0);
          break;
        case 5:
          final timeA = _parseTime(a.appointmentTime);
          final timeB = _parseTime(b.appointmentTime);
          
          if (timeA == null && timeB == null) {
            comparison = 0;
          } else if (timeA == null) {
            comparison = -1; // null значения в начале
          } else if (timeB == null) {
            comparison = 1;
          } else {
            final aDouble = timeA.hour + timeA.minute / 60.0;
            final bDouble = timeB.hour + timeB.minute / 60.0;
            comparison = aDouble.compareTo(bDouble);
          }
          break;
        case 6: // Status
          comparison = a.status.compareTo(b.status);
          break;
        default:
          comparison = 0;
      }
      return newIsAscending ? comparison : -comparison;
    });

    emit(state.copyWith(
      displayedRows: sortedRows,
      sortColumnIndex: newSortColumnIndex,
      isAscending: newIsAscending,
    ));
  }

  void _onFilterReport(FilterReport event, Emitter<ReportState> emit) {
    List<DailyReportRowEntity> filteredRows = List.from(state.allRows);

    // Apply Doctor Filter
    if (event.doctorFilter != null && event.doctorFilter != 'Все') {
      filteredRows = filteredRows
          .where((row) => row.doctorFullName == event.doctorFilter)
          .toList();
    }

    // Apply Status Filter
    if (event.statusFilter != null && event.statusFilter != 'Все') {
      filteredRows = filteredRows
          .where((row) => row.status == event.statusFilter)
          .toList();
    }
    
    if (event.startTimeFilter != null) {
      filteredRows = filteredRows.where((row) {
        if (row.appointmentTime == null) return false;
        try {
          final timeParts = row.appointmentTime!.split(':');
          final rowTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
          final filterTime = event.startTimeFilter!;
          return (rowTime.hour > filterTime.hour) || (rowTime.hour == filterTime.hour && rowTime.minute >= filterTime.minute);
        } catch (e) {
          return false;
        }
      }).toList();
    }
    
    if (event.endTimeFilter != null) {
      filteredRows = filteredRows.where((row) {
        if (row.appointmentTime == null) return false;
        try {
          final timeParts = row.appointmentTime!.split(':');
          final rowTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
          final filterTime = event.endTimeFilter!;
          return (rowTime.hour < filterTime.hour) || (rowTime.hour == filterTime.hour && rowTime.minute <= filterTime.minute);
        } catch (e) {
          return false;
        }
      }).toList();
    }

    emit(state.copyWith(
      displayedRows: filteredRows,
      doctorFilter: event.doctorFilter,
      statusFilter: event.statusFilter,
      startTimeFilter: event.startTimeFilter,
      endTimeFilter: event.endTimeFilter,
    ));
    
    add(SortReport(columnIndex: state.sortColumnIndex, ascending: state.isAscending));
  }
}