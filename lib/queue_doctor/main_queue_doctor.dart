import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/datasources/waiting_screen_remote_data_source.dart';
import 'data/repositories/waiting_screen_repository_impl.dart';
import 'domain/repositories/waiting_screen_repository.dart';
import 'domain/usecases/get_waiting_screen_data.dart';
import 'presentation/blocs/waiting_screen_bloc.dart';
import 'presentation/blocs/waiting_screen_event.dart';
import 'presentation/blocs/waiting_screen_state.dart';
import 'presentation/pages/waiting_screen_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final WaitingScreenRemoteDataSource remoteDataSource =
      WaitingScreenRemoteDataSourceImpl();
  final WaitingScreenRepository repository =
      WaitingScreenRepositoryImpl(remoteDataSource: remoteDataSource);
  final GetWaitingScreenData getWaitingScreenData =
      GetWaitingScreenData(repository);

  runApp(MyApp(
    getWaitingScreenData: getWaitingScreenData,
    repository: repository,
  ));
}

class MyApp extends StatelessWidget {
  final GetWaitingScreenData getWaitingScreenData;
  final WaitingScreenRepository repository;

  const MyApp(
      {super.key,
      required this.getWaitingScreenData,
      required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Табло ожидания',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');
        // Проверяем URL: если есть номер кабинета (например, /#/101),
        // то pathSegments будет содержать '101'
        if (uri.pathSegments.isNotEmpty && uri.pathSegments.first.isNotEmpty) {
          try {
            final cabinetNumber = int.parse(uri.pathSegments.first);
            return MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => WaitingScreenBloc(
                  getWaitingScreenData: getWaitingScreenData,
                  repository: repository,
                )..add(LoadWaitingScreen(cabinetNumber: cabinetNumber)),
                child: WaitingScreenPage(cabinetNumber: cabinetNumber),
              ),
            );
          } catch (e) {
            // Если не удалось распознать номер, покажем страницу выбора
          }
        }

        // Страница по умолчанию: выбор кабинета
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => WaitingScreenBloc(
              getWaitingScreenData: getWaitingScreenData,
              repository: repository,
            )..add(InitializeCabinetSelection()), // Запускаем загрузку кабинетов
            child: const CabinetSelectionPage(),
          ),
        );
      },
    );
  }
}

/// Виджет для страницы выбора кабинета
class CabinetSelectionPage extends StatefulWidget {
  const CabinetSelectionPage({super.key});

  @override
  State<CabinetSelectionPage> createState() => _CabinetSelectionPageState();
}

class _CabinetSelectionPageState extends State<CabinetSelectionPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context
          .read<WaitingScreenBloc>()
          .add(FilterCabinets(query: _searchController.text));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите кабинет'),
        centerTitle: true,
      ),
      body: BlocBuilder<WaitingScreenBloc, WaitingScreenState>(
        builder: (context, state) {
          if (state is WaitingScreenLoading || state is WaitingScreenInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WaitingScreenError) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Ошибка: ${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, color: Colors.red)),
            ));
          }
          if (state is CabinetSelection) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Поиск по номеру кабинета',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                if (state.filteredCabinets.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                          state.allCabinets.isEmpty
                              ? 'На сегодня нет активных кабинетов'
                              : 'Кабинет не найден',
                          style: const TextStyle(fontSize: 18)),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.filteredCabinets.length,
                      itemBuilder: (context, index) {
                        final cabinetNumber = state.filteredCabinets[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: ListTile(
                            title: Text('Кабинет $cabinetNumber',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500)),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Используем стандартный навигатор для изменения хеша в URL
                              Navigator.of(context).pushNamed('/$cabinetNumber');
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          }
          // Запасной вариант, который не должен сработать
          return const Center(child: Text('Неожиданное состояние приложения'));
        },
      ),
    );
  }
}