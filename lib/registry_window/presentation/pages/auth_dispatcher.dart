import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/auth_token_service.dart';
import '../blocs/auth/auth_bloc.dart';
import 'auth_page.dart';
import 'ticket_queue_page.dart';

class AuthDispatcher extends StatefulWidget {
  const AuthDispatcher({super.key});

  @override
  State<AuthDispatcher> createState() => _AuthDispatcherState();
}

class _AuthDispatcherState extends State<AuthDispatcher> {
  final AuthTokenService _tokenService = AuthTokenService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tokenService.token != null) {
        context.read<AuthBloc>().add(const AuthSessionRestored());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          return const TicketQueuePage();
        }
        return LoginPage();
      },
    );
  }
}
