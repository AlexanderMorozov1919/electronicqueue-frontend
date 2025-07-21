import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/waiting_screen_bloc.dart';
import '../blocs/waiting_screen_state.dart';

class WaitingScreenPage extends StatelessWidget {
  final int cabinetNumber;

  const WaitingScreenPage({super.key, required this.cabinetNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return BlocBuilder<WaitingScreenBloc, WaitingScreenState>(
            builder: (context, state) {
              // --- ИЗМЕНЕНИЕ ЗДЕСЬ ---
              // Показываем загрузку и для Initial, и для Loading состояния
              if (state is WaitingScreenInitial || state is WaitingScreenLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Отображение состояния "Нет приема"
              if (state is WaitingScreenNoReception) {
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 70,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (state is WaitingScreenError) {
                return Container(
                  color: Colors.amber[100],
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Произошла ошибка:\n${state.message}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, color: Colors.red),
                      ),
                    ),
                  ),
                );
              }

              final bool isWaiting = state is WaitingScreenWaiting;
              final Color backgroundColor = isWaiting
                  ? const Color.fromARGB(255, 131, 211, 134) // Зеленый
                  : const Color.fromARGB(255, 224, 123, 123); // Красный

              String doctorName = '';
              String specialty = '';
              int cabinetNum = 0;
              String statusText = '';

              if (state is WaitingScreenWaiting) {
                doctorName = state.doctorName;
                specialty = state.doctorSpecialty;
                cabinetNum = state.cabinetNumber;
                statusText = 'Ожидайте приглашения';
              } else if (state is WaitingScreenCalled) {
                doctorName = state.doctorName;
                specialty = state.doctorSpecialty;
                cabinetNum = state.cabinetNumber;
                statusText = 'Приглашен талон:\n${state.ticketNumber}';
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                color: backgroundColor,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: constraints.maxHeight * 0.05,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeader(
                            doctorName, specialty, cabinetNum, constraints),
                        SizedBox(height: constraints.maxHeight * 0.1),
                        _buildStatusCard(statusText, constraints),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(String doctorName, String specialty, int cabinetNumber,
      BoxConstraints constraints) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Кабинет: $cabinetNumber',
              style: const TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 0.9)),
        ),
        SizedBox(height: constraints.maxHeight * 0.05),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(doctorName,
              style: const TextStyle(
                  fontSize: 70, color: Colors.black, height: 0.9)),
        ),
        SizedBox(height: constraints.maxHeight * 0.05),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(specialty,
              style: const TextStyle(
                  fontSize: 70, color: Colors.black, height: 0.9)),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String text, BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.9,
      margin: EdgeInsets.only(top: constraints.maxHeight * 0.05),
      padding: EdgeInsets.symmetric(
        vertical: constraints.maxHeight * 0.05,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text,
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 70, fontWeight: FontWeight.bold)),
      ),
    );
  }
}