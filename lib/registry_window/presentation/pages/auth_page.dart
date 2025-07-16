import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/auth/auth_card.dart';
import '../../domain/entities/auth_entity.dart';
import '../blocs/auth/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AuthCard(
          formKey: _formKey,
          loginController: _loginController,
          passwordController: _passwordController,
          onLoginPressed: () {
            if (_formKey.currentState!.validate()) {
              final authEntity = AuthEntity(
                login: _loginController.text.trim(),
                password: _passwordController.text.trim(),
              );
              context.read<AuthBloc>().add(
                    LoginButtonPressed(authEntity: authEntity),
                  );
            }
          },
        ),
      ),
    );
  }
}