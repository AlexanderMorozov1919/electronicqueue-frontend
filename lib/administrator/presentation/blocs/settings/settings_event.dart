part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object> get props => [];
}

class LoadProcesses extends SettingsEvent {}

class ToggleProcess extends SettingsEvent {
  final String processName;
  final bool isEnabled;

  const ToggleProcess({required this.processName, required this.isEnabled});
  
  @override
  List<Object> get props => [processName, isEnabled];
}