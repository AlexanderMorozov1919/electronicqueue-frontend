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
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1B4193),
          secondary: Color(0xFF2563EB),
          surface: Color(0xFFF8FAFC),
        ),
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
                ),
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

class _CabinetSelectionPageState extends State<CabinetSelectionPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _searchController.addListener(() {
      context
          .read<WaitingScreenBloc>()
          .add(FilterCabinets(query: _searchController.text));
    });

    _fadeController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernAppBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: BlocBuilder<WaitingScreenBloc, WaitingScreenState>(
                    builder: (context, state) {
                      if (state is WaitingScreenLoading ||
                          state is WaitingScreenInitial) {
                        return _buildLoadingState();
                      }
                      if (state is WaitingScreenError) {
                        return _buildErrorState(state.message);
                      }
                      if (state is CabinetSelection) {
                        return _buildCabinetList(state);
                      }
                      return _buildUnknownState();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B4193), Color(0xFF2563EB), Color(0xFF3B82F6)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF), // Colors.white.withOpacity(0.1)
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Электронная очередь',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Выберите кабинет для отображения',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xCCFFFFFF), // Colors.white.withOpacity(0.8)
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildModernSearchField(),
        ],
      ),
    );
  }

  Widget _buildModernSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000), // Colors.black.withOpacity(0.1)
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          labelText: 'Поиск по номеру кабинета',
          labelStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF1B4193),
            size: 24,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF6B7280)),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1B4193), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              color: Color(0xFF1B4193),
              strokeWidth: 4,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Загружаем список кабинетов...',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1A000000), // Colors.black.withOpacity(0.1)
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ошибка загрузки',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<WaitingScreenBloc>()
                    .add(InitializeCabinetSelection());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4193),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCabinetList(CabinetSelection state) {
    return Column(
      children: [
        if (state.filteredCabinets.isEmpty) _buildEmptyState(state),
        if (state.filteredCabinets.isNotEmpty) _buildCabinetGrid(state),
      ],
    );
  }

  Widget _buildEmptyState(CabinetSelection state) {
    return Expanded(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0x0D000000), // Colors.black.withOpacity(0.05)
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  state.allCabinets.isEmpty ? Icons.event_busy : Icons.search_off,
                  size: 64,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                state.allCabinets.isEmpty
                    ? 'Нет активных кабинетов'
                    : 'Кабинет не найден',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.allCabinets.isEmpty
                    ? 'На сегодня нет активных кабинетов для отображения'
                    : 'Попробуйте изменить критерии поиска',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCabinetGrid(CabinetSelection state) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: state.filteredCabinets.length,
          itemBuilder: (context, index) {
            final cabinetNumber = state.filteredCabinets[index];
            return _buildCabinetCard(cabinetNumber, index);
          },
        ),
      ),
    );
  }

  Widget _buildCabinetCard(int cabinetNumber, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF8FAFC)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x14000000), // Colors.black.withOpacity(0.08)
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.of(context).pushNamed('/$cabinetNumber');
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1B4193), Color(0xFF2563EB)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x4D1B4193), // Color(0xFF1B4193).withOpacity(0.3)
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.meeting_room,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$cabinetNumber',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Кабинет',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF8FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: Color(0xFF2563EB),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Открыть',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnknownState() {
    return const Center(
      child: Text(
        'Неожиданное состояние приложения',
        style: TextStyle(
          fontSize: 18,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}