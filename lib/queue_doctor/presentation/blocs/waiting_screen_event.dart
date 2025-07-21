import 'package:equatable/equatable.dart';

abstract class WaitingScreenEvent extends Equatable {
  const WaitingScreenEvent();

  @override
  List<Object> get props => [];
}

class InitializeCabinetSelection extends WaitingScreenEvent {}

class FilterCabinets extends WaitingScreenEvent {
  final String query;

  const FilterCabinets({required this.query});

  @override
  List<Object> get props => [query];
}

class LoadWaitingScreen extends WaitingScreenEvent {
  final int cabinetNumber;

  const LoadWaitingScreen({required this.cabinetNumber});

  @override
  List<Object> get props => [cabinetNumber];
}