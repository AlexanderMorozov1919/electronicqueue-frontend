part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class TogglePriority extends SettingsEvent {
  final int serviceId;
  const TogglePriority(this.serviceId);
  @override
  List<Object> get props => [serviceId];
}

class SavePriorities extends SettingsEvent {}