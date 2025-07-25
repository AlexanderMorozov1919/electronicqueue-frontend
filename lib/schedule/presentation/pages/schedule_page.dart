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
    // Запускаем подписку на события сразу при инициализации страницы
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
      body: BlocListener<ScheduleBloc, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка загрузки расписания: ${state.message}')),
            );
          }
        },
        child: ScheduleWidget(),
      ),
    );
  }
}