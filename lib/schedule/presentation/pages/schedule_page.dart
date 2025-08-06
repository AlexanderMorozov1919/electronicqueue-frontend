import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/schedule_widget.dart';
import '../blocs/schedule_bloc.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  void initState() {
    super.initState();
    // Инициируем подписку на обновления при создании страницы
    context.read<ScheduleBloc>().add(SubscribeToScheduleUpdates());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F3F4),
        title: const Text('Расписание врачей'),
        centerTitle: true,
      ),
      // Убираем BlocListener, так как обработка ошибок теперь происходит внутри ScheduleWidget
      body: const ScheduleWidget(),
    );
  }
}