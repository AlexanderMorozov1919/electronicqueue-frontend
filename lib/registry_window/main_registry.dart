import 'package:elqueue/registry_window/data/datasources/appointment_remote_data_source.dart';
import 'package:elqueue/registry_window/data/datasources/patient_remote_data_source.dart';
import 'package:elqueue/registry_window/domain/repositories/appointment_repository_impl.dart';
import 'package:elqueue/registry_window/data/repositories/patient_repository_impl.dart';
import 'package:elqueue/registry_window/domain/repositories/appointment_repository.dart';
import 'package:elqueue/registry_window/domain/repositories/patient_repository.dart';
import 'package:elqueue/registry_window/presentation/blocs/appointment/appointment_bloc.dart';
import 'package:elqueue/registry_window/presentation/blocs/report/report_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'data/datasources/ticket_remote_data_source.dart';
import 'data/repositories/ticket_repository_impl.dart';
import 'domain/repositories/ticket_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/ticket/ticket_bloc.dart';
import 'domain/usecases/authenticate_user.dart';
import 'domain/usecases/call_next_ticket.dart';
import 'domain/usecases/call_specific_ticket.dart';
import 'domain/usecases/complete_current_ticket.dart';
import 'domain/usecases/get_current_ticket.dart';
import 'domain/usecases/get_tickets_by_category.dart';
import 'domain/usecases/register_current_ticket.dart';
import 'data/services/auth_token_service.dart';
import 'presentation/pages/auth_dispatcher.dart';
import 'presentation/pages/ticket_queue_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Инициализируем сервис для загрузки токена из хранилища
  final authTokenService = AuthTokenService();
  await authTokenService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final httpClient = http.Client();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(client: httpClient),
        ),
        RepositoryProvider<TicketRepository>(
          create: (context) => TicketRepositoryImpl(
            remoteDataSource: TicketRemoteDataSourceImpl(client: httpClient),
          ),
        ),
        RepositoryProvider<AppointmentRepository>(
          create: (context) => AppointmentRepositoryImpl(
            remoteDataSource: AppointmentRemoteDataSourceImpl(
              client: httpClient,
            ),
          ),
        ),
        RepositoryProvider<PatientRepository>(
          create: (context) => PatientRepositoryImpl(
            remoteDataSource: PatientRemoteDataSourceImpl(client: httpClient),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authenticateUser: AuthenticateUser(
                context.read<AuthRepository>(),
              ),
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => TicketBloc(
              callNextTicket: CallNextTicket(
                RepositoryProvider.of<TicketRepository>(context),
              ),
              callSpecificTicket: CallSpecificTicket(
                RepositoryProvider.of<TicketRepository>(context),
              ),
              registerCurrentTicket: RegisterCurrentTicket(
                RepositoryProvider.of<TicketRepository>(context),
              ),
              completeCurrentTicket: CompleteCurrentTicket(
                RepositoryProvider.of<TicketRepository>(context),
              ),
              getCurrentTicket: GetCurrentTicket(
                RepositoryProvider.of<TicketRepository>(context),
              ),
              getTicketsByCategory: GetTicketsByCategory(
                RepositoryProvider.of<TicketRepository>(context),
              ),
            ),
          ),
          BlocProvider(
            create: (context) => AppointmentBloc(
              appointmentRepository: context.read<AppointmentRepository>(),
              patientRepository: context.read<PatientRepository>(),
            ),
          ),
          // НОВАЯ РЕГИСТРАЦИЯ BLOC
          BlocProvider(
            create: (context) => ReportBloc(
              ticketRepository: context.read<TicketRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Кабинет регистратуры',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const AuthDispatcher(),
          routes: {
            '/login': (context) => const AuthDispatcher(),
            '/main': (context) => const TicketQueuePage(),
          },
        ),
      ),
    );
  }
}