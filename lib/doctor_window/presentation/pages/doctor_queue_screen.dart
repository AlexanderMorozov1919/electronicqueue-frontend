import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../data/repositories/queue_repository_impl.dart';
import '../../domain/usecases/end_appointment.dart';
import '../../domain/usecases/get_queue_status.dart';
import '../../domain/usecases/start_appointment.dart';
import '../../domain/usecases/watch_queue_updates.dart';
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
        title: const Text('Кабинет врача'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            color: Colors.black45,
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) {
          final doctorApi = DoctorApi();
          final queueDataSource = RemoteQueueDataSource(
            api: doctorApi,
            client: http.Client(),
          );
          final queueRepository = QueueRepositoryImpl(
            dataSource: queueDataSource,
          );

          return QueueBloc(
            getQueueStatus: GetQueueStatus(queueRepository),
            startAppointment: StartAppointment(queueRepository),
            endAppointment: EndAppointment(queueRepository),
            watchQueueUpdates: WatchQueueUpdates(queueRepository),
          )..add(LoadQueueEvent());
        },
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: QueueStatusWidget(),
        ),
      ),
    );
  }
}
