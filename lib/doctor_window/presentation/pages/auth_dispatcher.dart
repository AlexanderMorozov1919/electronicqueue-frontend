import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/auth_service.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import 'auth_page.dart';
import 'doctor_queue_screen.dart';

class AuthDispatcher extends StatefulWidget {
  const AuthDispatcher({super.key});

  @override
  State<AuthDispatcher> createState() => _AuthDispatcherState();
}

class _AuthDispatcherState extends State<AuthDispatcher> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_authService.token != null && _authService.doctor != null) {
        context.read<AuthBloc>().emit(
          AuthSuccess(doctor: _authService.doctor!),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          return const DoctorQueueScreen();
        }
        return const AuthScreen();
      },
    );
  }
}
