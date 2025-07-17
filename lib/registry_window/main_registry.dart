import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'data/datasources/ticket_remote_data_source.dart';
import 'presentation/pages/ticket_queue_page.dart';
import 'data/repositories/ticket_repository_impl.dart';
import 'domain/repositories/ticket_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/pages/auth_page.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'domain/usecases/authenticate_user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(),
        ),
        RepositoryProvider<TicketRepository>(
          create: (context) => TicketRepositoryImpl(
            remoteDataSource: TicketRemoteDataSourceImpl(client: http.Client()),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authenticateUser: AuthenticateUser(
                RepositoryProvider.of<AuthRepository>(context),
              ),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Кабинет регистратуры',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginPage(),
            '/main': (context) => const TicketQueuePage(),
          },
        ),
      ),
    );
  }
}