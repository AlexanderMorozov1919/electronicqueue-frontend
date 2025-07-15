import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/datasourcers/auth_local_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/sign_in.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/pages/auth_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            signIn: SignIn(
              AuthRepositoryImpl(
                localDataSource: AuthLocalDataSource(),
              ),
            ),
            authRepository: AuthRepositoryImpl(
              localDataSource: AuthLocalDataSource(),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Кабинет врача',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthScreen(),
      ),
    );
  }
}