import 'package:flutter/material.dart';
import 'login_field.dart';
import 'password_field.dart';
import 'login_button.dart';

class AuthCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController loginController;
  final TextEditingController passwordController;
  final VoidCallback onLoginPressed;

  const AuthCard({
    super.key,
    required this.formKey,
    required this.loginController,
    required this.passwordController,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Авторизация',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              LoginField(controller: loginController),
              const SizedBox(height: 16),
              PasswordField(controller: passwordController),
              const SizedBox(height: 32),
              LoginButton(onPressed: onLoginPressed),
            ],
          ),
        ),
      ),
    );
  }
}