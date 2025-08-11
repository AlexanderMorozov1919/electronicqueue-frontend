part of 'report_bloc.dart';

class ReportState extends Equatable {
  final List<DailyReportRowEntity> allRows;
  final List<DailyReportRowEntity> displayedRows;
  final bool isLoading;
  final String? error;
  final int sortColumnIndex;
  final bool isAscending;
  final String? doctorFilter;
  final String? statusFilter;
  final TimeOfDay? startTimeFilter;
  final TimeOfDay? endTimeFilter;

  const ReportState({
    this.allRows = const [],
    this.displayedRows = const [],
    this.isLoading = false,
    this.error,
    this.sortColumnIndex = 0,
    this.isAscending = true,
    this.doctorFilter,
    this.statusFilter,
    this.startTimeFilter,
    this.endTimeFilter,
  });

  ReportState copyWith({
    List<DailyReportRowEntity>? allRows,
    List<DailyReportRowEntity>? displayedRows,
    bool? isLoading,
    String? error,
    int? sortColumnIndex,
    bool? isAscending,
    String? doctorFilter,
    String? statusFilter,
    TimeOfDay? startTimeFilter,
    TimeOfDay? endTimeFilter,
    bool clearError = false,
    bool clearFilters = false,
  }) {
    return ReportState(
      allRows: allRows ?? this.allRows,
      displayedRows: displayedRows ?? this.displayedRows,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error,
      sortColumnIndex: sortColumnIndex ?? this.sortColumnIndex,
      isAscending: isAscending ?? this.isAscending,
      doctorFilter: clearFilters ? null : doctorFilter ?? this.doctorFilter,
      statusFilter: clearFilters ? null : statusFilter ?? this.statusFilter,
      startTimeFilter: clearFilters ? null : startTimeFilter ?? this.startTimeFilter,
      endTimeFilter: clearFilters ? null : endTimeFilter ?? this.endTimeFilter,
    );
  }

  @override
  List<Object?> get props => [
        allRows,
        displayedRows,
        isLoading,
        error,
        sortColumnIndex,
        isAscending,
        doctorFilter,
        statusFilter,
        startTimeFilter,
        endTimeFilter,
      ];
}