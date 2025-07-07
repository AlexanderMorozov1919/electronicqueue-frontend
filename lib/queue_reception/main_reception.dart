import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/screens/queue_display_page.dart';
import 'presentation/blocs/queue_display_bloc.dart';
import 'data/repositories/queue_repository_impl.dart';
import 'data/datasources/queue_remote_datasource.dart';
import 'presentation/blocs/queue_display_event.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => QueueDisplayBloc(
            QueueRepositoryImpl(FakeQueueRemoteDataSource()),
          )..add(LoadTicketsEvent()),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: QueueDisplayPage(),
      ),
    ),
  );
}