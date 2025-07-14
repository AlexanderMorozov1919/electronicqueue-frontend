import 'package:bloc/bloc.dart';
import 'waiting_screen_event.dart';
import 'waiting_screen_state.dart';

class WaitingScreenBloc extends Bloc<WaitingScreenEvent, WaitingScreenState> {
  WaitingScreenBloc() : super(WaitingScreenWaiting(
    doctorName: 'Иванов Иван Иванович',
    doctorSpecialty: 'Терапевт',
    officeNumber: 1,
  )) {
    on<ToggleCallPatient>((event, emit) {
      if (state is WaitingScreenWaiting) {
        emit(WaitingScreenCalled(
          doctorName: (state as WaitingScreenWaiting).doctorName,
          doctorSpecialty: (state as WaitingScreenWaiting).doctorSpecialty,
          officeNumber: (state as WaitingScreenWaiting).officeNumber,
          ticketNumber: 'A${DateTime.now().second}', // Генерируем случайный номер
        ));
      } else {
        emit(WaitingScreenWaiting(
          doctorName: (state as WaitingScreenCalled).doctorName,
          doctorSpecialty: (state as WaitingScreenCalled).doctorSpecialty,
          officeNumber: (state as WaitingScreenCalled).officeNumber,
        ));
      }
    });
  }
}