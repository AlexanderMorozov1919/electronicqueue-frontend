import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/pages/ticket_queue_page.dart';
import 'data/datasources/ticket_local_data_source.dart';
import 'data/repositories/ticket_repository_impl.dart';
import 'domain/repositories/ticket_repository.dart';
import 'data/api/registry_api.dart'; // <-- ИМПОРТИРУЕМ API

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Создаем единственный экземпляр API клиента
    final registryApi = RegistryApi();

    return RepositoryProvider<TicketRepository>(
      create: (context) => TicketRepositoryImpl(
        // Теперь наш локальный источник данных требует API
        localDataSource: TicketLocalDataSourceImpl(api: registryApi),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Электронная очередь',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const TicketQueuePage(),
      ),
    );
  }
}
