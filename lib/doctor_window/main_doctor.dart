import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'data/datasourcers/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/services/auth_service.dart';
import 'domain/usecases/sign_in.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/pages/auth_dispatcher.dart';
import 'presentation/blocs/auth/auth_event.dart';

// --- ИЗМЕНЕНИЕ: ИМПОРТ ПЕРЕХВАТЧИКА ---
import '../../../core/http/http_client_interceptor.dart';

// --- ИЗМЕНЕНИЕ: ГЛОБАЛЬНЫЙ КЛЮЧ НАВИГАТОРА ---
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final authService = AuthService();
  await authService.initialize();

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    // --- ИЗМЕНЕНИЕ: СОЗДАНИЕ HTTP-КЛИЕНТА С ПЕРЕХВАТЧИКОМ ---
    final httpClient = HttpClientInterceptor(
      http.Client(),
      authService, // AuthService реализует нужный интерфейс
      () {
        // Функция выхода при получении 401 ошибки
        navigatorKey.currentContext?.read<AuthBloc>().add(SignOutRequested());
      },
    );

    // --- ИЗМЕНЕНИЕ: Передаем httpClient в AuthRemoteDataSource ---
    final authRemoteDataSource = AuthRemoteDataSource(client: httpClient);
    final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            signIn: SignIn(authRepository),
            authRepository: authRepository,
          ),
        ),
      ],
      child: MaterialApp(
        // --- ИЗМЕНЕНИЕ: ДОБАВЛЕНИЕ КЛЮЧА НАВИГАТОРА ---
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Кабинет врача',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
        ),
        home: const AuthDispatcher(),
      ),
    );
  }
}