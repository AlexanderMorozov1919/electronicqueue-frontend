import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/datasources/waiting_screen_remote_data_source.dart';
import 'data/repositories/waiting_screen_repository_impl.dart';
import 'domain/repositories/waiting_screen_repository.dart';
import 'domain/usecases/get_waiting_screen_data.dart';
import 'presentation/blocs/waiting_screen_bloc.dart';
import 'presentation/blocs/waiting_screen_event.dart';
import 'presentation/pages/waiting_screen_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  final WaitingScreenRemoteDataSource remoteDataSource = WaitingScreenRemoteDataSourceImpl();
  final WaitingScreenRepository repository = WaitingScreenRepositoryImpl(remoteDataSource: remoteDataSource);
  final GetWaitingScreenData getWaitingScreenData = GetWaitingScreenData(repository);

  runApp(MyApp(getWaitingScreenData: getWaitingScreenData));
}

class MyApp extends StatelessWidget {
  final GetWaitingScreenData getWaitingScreenData;

  const MyApp({super.key, required this.getWaitingScreenData});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Табло ожидания',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => WaitingScreenBloc(
          getWaitingScreenData: getWaitingScreenData,
        )..add(LoadWaitingScreen()),
        child: const WaitingScreenPage(),
      ),
    );
  }
}