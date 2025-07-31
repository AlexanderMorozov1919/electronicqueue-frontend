part of 'report_bloc.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object?> get props => [];
}

class LoadDailyReport extends ReportEvent {}

class SortReport extends ReportEvent {
  final int columnIndex;
  final bool ascending;

  const SortReport({required this.columnIndex, required this.ascending});

  @override
  List<Object?> get props => [columnIndex, ascending];
}

class FilterReport extends ReportEvent {
  final String? doctorFilter;
  final String? statusFilter;
  final TimeOfDay? startTimeFilter;
  final TimeOfDay? endTimeFilter;

  const FilterReport({
    this.doctorFilter,
    this.statusFilter,
    this.startTimeFilter,
    this.endTimeFilter,
  });

  @override
  List<Object?> get props => [doctorFilter, statusFilter, startTimeFilter, endTimeFilter];
}