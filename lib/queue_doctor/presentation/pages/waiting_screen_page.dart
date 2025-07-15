import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/waiting_screen_bloc.dart';
import '../blocs/waiting_screen_state.dart';
import '../blocs/waiting_screen_event.dart';

class WaitingScreenPage extends StatelessWidget {
  const WaitingScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: BlocBuilder<WaitingScreenBloc, WaitingScreenState>(
                builder: (context, state) {
                  final isWaiting = state is WaitingScreenWaiting || state is WaitingScreenInitial;
                  
                  return Container(
                    height: constraints.maxHeight,
                    color: isWaiting ? const Color.fromARGB(255, 131, 211, 134) 
                                   : const Color.fromARGB(255, 224, 123, 123),
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
                              isWaiting 
                                ? (state as WaitingScreenWaiting).doctorName 
                                : (state as WaitingScreenCalled).doctorName,
                              isWaiting 
                                ? (state as WaitingScreenWaiting).doctorSpecialty 
                                : (state as WaitingScreenCalled).doctorSpecialty,
                              isWaiting 
                                ? (state as WaitingScreenWaiting).officeNumber 
                                : (state as WaitingScreenCalled).officeNumber,
                              constraints,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.1), 
                            _buildStatusCard(
                              isWaiting 
                                ? 'Ожидайте приглашения' 
                                : 'Приглашен талон: ${(state as WaitingScreenCalled).ticketNumber}',
                              constraints,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      // Тут просто кнопка для теста обоих состояний
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<WaitingScreenBloc>().add(ToggleCallPatient());
        },
        child: const Icon(Icons.person),
        tooltip: 'Вызвать следующего',
      ),
    );
  }

  Widget _buildHeader(String doctorName, String specialty, int officeNumber, BoxConstraints constraints) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Кабинет: $officeNumber',
            style: TextStyle(
              fontSize: 70,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 0.9,
            ),
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.05), 
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            doctorName,
            style: TextStyle(
              fontSize: 70,
              color: Colors.black,
              height: 0.9,
            ),
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.05), 
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            specialty,
            style: TextStyle(
              fontSize: 70,
              color: Colors.black,
              height: 0.9,
            ),
          ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}