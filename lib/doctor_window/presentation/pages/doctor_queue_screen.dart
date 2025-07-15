import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasourcers/local_queue_data_source.dart';
import '../../data/repositories/queue_repository_impl.dart';
import '../../domain/usecases/end_appointment.dart';
import '../../domain/usecases/get_queue_status.dart';
import '../../domain/usecases/start_appointment.dart';
import '../blocs/queue_bloc.dart';
import '../widgets/queue_status_widget.dart';
import '../blocs/queue_event.dart';

class DoctorQueueScreen extends StatelessWidget {
  const DoctorQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Электронная очередь'),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) => QueueBloc(
          getQueueStatus: GetQueueStatus(
            QueueRepositoryImpl(
              dataSource: LocalQueueDataSource(),
            ),
          ),
          startAppointment: StartAppointment(
            QueueRepositoryImpl(
              dataSource: LocalQueueDataSource(),
            ),
          ),
          endAppointment: EndAppointment(
            QueueRepositoryImpl(
              dataSource: LocalQueueDataSource(),
            ),
          ),
        )..add(LoadQueueEvent()),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: QueueStatusWidget(),
        ),
      ),
    );
  }
}