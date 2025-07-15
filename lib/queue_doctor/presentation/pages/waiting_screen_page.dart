import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/waiting_screen_bloc.dart';
import '../blocs/waiting_screen_state.dart';

class WaitingScreenPage extends StatelessWidget {
  const WaitingScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return BlocBuilder<WaitingScreenBloc, WaitingScreenState>(
            builder: (context, state) {
              if (state is WaitingScreenLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is WaitingScreenError) {
                return Center(
                  child: Text(
                    'Ошибка подключения: ${state.message}',
                    style: const TextStyle(fontSize: 24, color: Colors.red),
                  ),
                );
              }

              final bool isWaiting = state is WaitingScreenWaiting;
              final Color backgroundColor = isWaiting
                  ? const Color.fromARGB(255, 131, 211, 134) // Зеленый
                  : const Color.fromARGB(255, 224, 123, 123); // Красный
              
              String doctorName = '';
              String specialty = '';
              int officeNumber = 0;
              String statusText = '';
              
              if (state is WaitingScreenWaiting) {
                  doctorName = state.doctorName;
                  specialty = state.doctorSpecialty;
                  officeNumber = state.officeNumber;
                  statusText = 'Ожидайте приглашения';
              } else if (state is WaitingScreenCalled) {
                  doctorName = state.doctorName;
                  specialty = state.doctorSpecialty;
                  officeNumber = state.officeNumber;
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
                        _buildHeader(doctorName, specialty, officeNumber, constraints),
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

  Widget _buildHeader(String doctorName, String specialty, int officeNumber, BoxConstraints constraints) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Кабинет: $officeNumber', style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.black, height: 0.9)),
        ),
        SizedBox(height: constraints.maxHeight * 0.05),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(doctorName, style: const TextStyle(fontSize: 70, color: Colors.black, height: 0.9)),
        ),
        SizedBox(height: constraints.maxHeight * 0.05),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(specialty, style: const TextStyle(fontSize: 70, color: Colors.black, height: 0.9)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold)),
      ),
    );
  }
}