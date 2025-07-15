import 'package:equatable/equatable.dart';

abstract class WaitingScreenEvent extends Equatable {
  const WaitingScreenEvent();

  @override
  List<Object> get props => [];
}

class LoadWaitingScreen extends WaitingScreenEvent {}

class ToggleCallPatient extends WaitingScreenEvent {} 