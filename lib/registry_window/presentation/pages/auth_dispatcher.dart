import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
      final token = _tokenService.token;
      if (token != null) {
        try {
          // Декодируем токен, чтобы получить номер окна
          final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          final windowNumber = decodedToken['window_number'] as int?;

          if (windowNumber != null) {
            // Если номер окна есть в токене, восстанавливаем сессию
            context
                .read<AuthBloc>()
                .add(AuthSessionRestored(windowNumber: windowNumber));
          } else {
            // Если токен есть, а номера окна нет (некорректный токен), выходим
            context.read<AuthBloc>().add(const LogoutRequested());
          }
        } catch (e) {
          // Если токен невалидный, выходим
          context.read<AuthBloc>().add(const LogoutRequested());
        }
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