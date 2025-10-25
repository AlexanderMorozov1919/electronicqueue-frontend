import 'package:elqueue/administrator/data/datasource/ad_remote_data_source.dart';
import 'package:elqueue/administrator/data/repositories/ad_repository_impl.dart';
import 'package:elqueue/administrator/domain/repositories/ad_repository.dart';
import 'package:elqueue/administrator/domain/usecases/manage_ads.dart';
import 'package:elqueue/administrator/presentation/blocs/ad/ad_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player_web/video_player_web.dart';

// --- ИЗМЕНЕНИЕ: ИМПОРТ ПЕРЕХВАТЧИКА И НОВОГО AUTH_TOKEN_SERVICE ---
import '../../../core/http/http_client_interceptor.dart';
import 'data/services/auth_token_service.dart';

import 'data/datasource/settings_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/usecases/authenticate_user.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/pages/auth_dispatcher.dart';

// --- ИЗМЕНЕНИЕ: ГЛОБАЛЬНЫЙ КЛЮЧ НАВИГАТОРА ---
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    VideoPlayerPlugin();
  }

  await dotenv.load(fileName: ".env");

  // Инициализируем сервис токенов, как и раньше
  final authTokenService = AuthTokenService();
  await authTokenService.initialize();

  // --- ИЗМЕНЕНИЕ: ПЕРЕДАЕМ СЕРВИС ТОКЕНОВ В WIDGET APP ---
  runApp(AdministratorApp(authTokenService: authTokenService));
}

class AdministratorApp extends StatelessWidget {
  // --- ИЗМЕНЕНИЕ: ПОЛУЧАЕМ AUTH_TOKEN_SERVICE ---
  final AuthTokenService authTokenService;

  const AdministratorApp({super.key, required this.authTokenService});

  @override
  Widget build(BuildContext context) {
    // --- ИЗМЕНЕНИЕ: СОЗДАЕМ HTTP-КЛИЕНТ С ПЕРЕХВАТЧИКОМ ---
    final httpClient = HttpClientInterceptor(
      http.Client(),
      authTokenService, // Передаем сервис токенов
      () {
        // Функция обратного вызова при ошибке 401 Unauthorized
        // Используем navigatorKey для доступа к BLoC и вызова выхода
        navigatorKey.currentContext?.read<AuthBloc>().add(const LogoutRequested());
      },
    );

    return MultiRepositoryProvider(
      providers: [
        // --- ИЗМЕНЕНИЕ: ИСПОЛЬЗУЕМ НОВЫЙ HTTPCLIENT ---
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(client: httpClient),
        ),
        RepositoryProvider<SettingsRepository>(
          create: (context) => SettingsRepositoryImpl(
            remoteDataSource: SettingsRemoteDataSource(client: httpClient),
          ),
        ),
        RepositoryProvider<AdRepository>(
          create: (context) => AdRepositoryImpl(
            remoteDataSource: AdRemoteDataSourceImpl(client: httpClient),
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
            create: (context) => SettingsBloc(
              settingsRepository: context.read<SettingsRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) {
              final repo = context.read<AdRepository>();
              return AdBloc(
                getAds: GetAds(repo),
                createAd: CreateAd(repo),
                updateAd: UpdateAd(repo),
                deleteAd: DeleteAd(repo),
              );
            },
          ),
        ],
        child: MaterialApp(
          // --- ИЗМЕНЕНИЕ: ПРИВЯЗЫВАЕМ КЛЮЧ НАВИГАТОРА ---
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Панель администратора',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            scaffoldBackgroundColor: const Color(0xFFF1F3F4),
            fontFamily: 'Roboto',
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const AuthDispatcher(),
        ),
      ),
    );
  }
}