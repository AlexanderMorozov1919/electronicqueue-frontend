import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/queue_repository_impl.dart';
import '../../domain/usecases/end_appointment.dart';
import '../../domain/usecases/get_queue_status.dart';
import '../../domain/usecases/start_appointment.dart';
import '../blocs/queue_bloc.dart';
import '../blocs/queue_event.dart';
import '../widgets/queue_status_widget.dart';
import '../blocs/auth/auth_bloc.dart';
import '../../data/datasourcers/remote_queue_data_source.dart';
import '../../data/api/doctor_api.dart';
import 'auth_page.dart';
import '../blocs/auth/auth_event.dart';

class DoctorQueueScreen extends StatelessWidget {
  const DoctorQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Электронная очередь'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.black45,
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => QueueBloc(
          getQueueStatus: GetQueueStatus(
            QueueRepositoryImpl(
              dataSource: RemoteQueueDataSource(DoctorApi()),
            ),
          ),
          startAppointment: StartAppointment(
            QueueRepositoryImpl(
              dataSource: RemoteQueueDataSource(DoctorApi()),
            ),
          ),
          endAppointment: EndAppointment(
            QueueRepositoryImpl(
              dataSource: RemoteQueueDataSource(DoctorApi()),
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