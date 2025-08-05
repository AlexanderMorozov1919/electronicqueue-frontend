import 'package:elqueue/administrator/data/datasource/ad_remote_data_source.dart';
import 'package:elqueue/administrator/data/repositories/ad_repository_impl.dart';
import 'package:elqueue/administrator/domain/repositories/ad_repository.dart';
import 'package:elqueue/administrator/domain/usecases/manage_ads.dart';
import 'package:elqueue/administrator/presentation/blocs/ad/ad_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'data/datasource/settings_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'data/services/auth_token_service.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/usecases/authenticate_user.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/pages/auth_dispatcher.dart';

void main() async {
  // Инициализация биндингов Flutter, обязательна перед асинхронными операциями
  WidgetsFlutterBinding.ensureInitialized();
  
  // Загрузка переменных окружения из файла .env
  await dotenv.load(fileName: ".env");

  // Инициализируем сервис для загрузки токена администратора из хранилища
  // Это нужно сделать до запуска приложения, чтобы проверить, авторизован ли пользователь.
  final authTokenService = AuthTokenService();
  await authTokenService.initialize();

  runApp(const AdministratorApp());
}

class AdministratorApp extends StatelessWidget {
  const AdministratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Создаем один экземпляр http.Client для всего приложения
    final httpClient = http.Client();

    // MultiRepositoryProvider используется для предоставления репозиториев
    // всем нижестоящим виджетам, в основном BLoC'ам.
    return MultiRepositoryProvider(
      providers: [
        // Репозиторий для аутентификации
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(client: httpClient),
        ),
        // Репозиторий для управления настройками сервера (бизнес-процессами)
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
          // BLoC для управления состоянием аутентификации
          BlocProvider(
            create: (context) => AuthBloc(
              authenticateUser: AuthenticateUser(
                context.read<AuthRepository>(),
              ),
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          // BLoC для управления состоянием настроек
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
          debugShowCheckedModeBanner: false,
          title: 'Панель администратора',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            scaffoldBackgroundColor: const Color(0xFFF1F3F4),
            fontFamily: 'Roboto',
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          // AuthDispatcher - это начальный экран, который решает,
          // показывать страницу входа или панель администратора.
          home: const AuthDispatcher(),
        ),
      ),
    );
  }
}