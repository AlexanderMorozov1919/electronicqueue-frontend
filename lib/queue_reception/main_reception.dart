import 'package:elqueue/queue_reception/data/datasources/ad_display_remote_datasource.dart';
import 'package:elqueue/queue_reception/data/repositories/ad_display_repository_impl.dart';
import 'package:elqueue/queue_reception/domain/repositories/ad_display_repository.dart';
import 'package:elqueue/queue_reception/presentation/blocs/ad_display_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/screens/queue_display_page.dart';
import 'presentation/blocs/queue_display_bloc.dart';
import 'data/repositories/queue_repository_impl.dart';
import 'data/datasources/queue_remote_datasource.dart';
import 'presentation/blocs/queue_display_event.dart';
import 'package:http/http.dart' as http;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final httpClient = http.Client();
  
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AdDisplayRepository>(
          create: (context) => AdDisplayRepositoryImpl(
            dataSource: AdDisplayRemoteDataSource(client: httpClient),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => QueueDisplayBloc(
              QueueRepositoryImpl(SseQueueRemoteDataSource()),
            )..add(LoadTicketsEvent()),
          ),
          BlocProvider(
            create: (context) => AdDisplayBloc(
              repository: context.read<AdDisplayRepository>(),
            )..add(FetchEnabledAds()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Roboto',
          ),
          home: const QueueDisplayPage(),
        ),
      ),
    ),
  );
}