import 'package:elqueue/schedule/data/datasources/schedule_remote_data_source.dart';
import 'package:elqueue/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:elqueue/schedule/domain/usecases/get_today_schedule.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/blocs/schedule_bloc.dart';
import 'presentation/pages/schedule_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('ru');

  final scheduleRemoteDataSource =
      ScheduleRemoteDataSourceImpl(client: http.Client());
  final scheduleRepository =
      ScheduleRepositoryImpl(remoteDataSource: scheduleRemoteDataSource);
  final getTodaySchedule = GetTodaySchedule(scheduleRepository);

  runApp(MyApp(getTodaySchedule: getTodaySchedule));
}

class MyApp extends StatelessWidget {
  final GetTodaySchedule getTodaySchedule;

  const MyApp({super.key, required this.getTodaySchedule});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Расписание врачей',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Manrope',
      ),
      home: BlocProvider<ScheduleBloc>(
        create: (context) => ScheduleBloc(getTodaySchedule: getTodaySchedule),
        child: const SchedulePage(),
      ),
    );
  }
}