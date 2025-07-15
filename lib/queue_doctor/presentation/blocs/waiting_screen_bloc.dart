import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/waiting_screen_entity.dart';
import '../../domain/usecases/get_waiting_screen_data.dart';
import 'waiting_screen_event.dart';
import 'waiting_screen_state.dart';


class WaitingScreenBloc extends Bloc<WaitingScreenEvent, WaitingScreenState> {
  final GetWaitingScreenData _getWaitingScreenData;

  WaitingScreenBloc({required GetWaitingScreenData getWaitingScreenData})
      : _getWaitingScreenData = getWaitingScreenData,
        super(WaitingScreenLoading()) {
    on<LoadWaitingScreen>(_onLoadWaitingScreen);
  }

  void _onLoadWaitingScreen(
    LoadWaitingScreen event,
    Emitter<WaitingScreenState> emit,
  ) async {
    await emit.forEach<WaitingScreenEntity>(
      _getWaitingScreenData(const NoParams()),
      onData: (entity) {
        if (entity.isCalled) {
          return WaitingScreenCalled(
            doctorName: entity.doctorName,
            doctorSpecialty: entity.doctorSpecialty,
            officeNumber: entity.officeNumber,
            ticketNumber: entity.currentTicket ?? '',
          );
        } else {
          return WaitingScreenWaiting(
            doctorName: entity.doctorName,
            doctorSpecialty: entity.doctorSpecialty,
            officeNumber: entity.officeNumber,
          );
        }
      },
      onError: (error, stackTrace) => WaitingScreenError(message: error.toString()),
    );
  }
}