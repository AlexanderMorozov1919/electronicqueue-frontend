import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/datasourcers/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/services/auth_service.dart';
import 'domain/usecases/sign_in.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/pages/auth_page.dart';
import 'presentation/pages/auth_dispatcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final authService = AuthService();
  await authService.initialize();

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
              AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSource()),
            ),
            authRepository: AuthRepositoryImpl(
              remoteDataSource: AuthRemoteDataSource(),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Кабинет врача',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthDispatcher(),
      ),
    );
  }
}
