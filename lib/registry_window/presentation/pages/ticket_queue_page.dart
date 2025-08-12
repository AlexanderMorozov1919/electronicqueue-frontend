import 'package:elqueue/registry_window/domain/repositories/registrar_repository.dart';
import 'package:elqueue/registry_window/domain/usecases/get_all_services.dart';
import 'package:elqueue/registry_window/domain/usecases/get_registrar_priorities.dart';
import 'package:elqueue/registry_window/domain/usecases/set_registrar_priorities.dart';
import 'package:elqueue/registry_window/presentation/blocs/settings/settings_bloc.dart';
import 'package:elqueue/registry_window/presentation/widgets/logout_button.dart';
import 'package:elqueue/registry_window/presentation/widgets/settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/ticket/ticket_bloc.dart';
import '../../core/constants/app_constans.dart';
import '../widgets/ticket_queue_view.dart';
import '../blocs/ticket/ticket_event.dart';
import '../blocs/auth/auth_bloc.dart';
import 'auth_page.dart';

// 1. Конвертируем в StatefulWidget
class TicketQueuePage extends StatefulWidget {
  const TicketQueuePage({super.key});

  @override
  State<TicketQueuePage> createState() => _TicketQueuePageState();
}

class _TicketQueuePageState extends State<TicketQueuePage> {

  // 2. Загружаем начальные данные в initState
  @override
  void initState() {
    super.initState();
    // Диспетчеризация событий в глобальный TicketBloc
    context.read<TicketBloc>()
      ..add(LoadCurrentTicketEvent())
      ..add(CheckAppointmentButtonStatus())
      ..add(LoadAvailableCategories());
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final windowNumber = authBloc.windowNumber ?? 1;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is! AuthSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false,
          );
        }
      },
      // 3. Убираем локальный BlocProvider<TicketBloc>
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F3F4),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF1F3F4),
          leading: IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Настройки приоритетов',
            onPressed: () {
              showDialog(
                context: context,
                // Используем локальный BlocProvider для диалога, что правильно
                builder: (_) => BlocProvider(
                  create: (dialogContext) => SettingsBloc(
                    getAllServices: GetAllServices(dialogContext.read<RegistrarRepository>()),
                    getPriorities: GetRegistrarPriorities(dialogContext.read<RegistrarRepository>()),
                    setPriorities: SetRegistrarPriorities(dialogContext.read<RegistrarRepository>()),
                  ),
                  child: const SettingsDialog(),
                ),
              ).then((_) {
                // 4. После закрытия диалога перезагружаем категории в ГЛОБАЛЬНОМ TicketBloc
                context.read<TicketBloc>().add(LoadAvailableCategories());
              });
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(AppConstants.appTitle),
              const SizedBox(width: 15),
              Chip(
                label: Text(
                  'Окно №$windowNumber',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                backgroundColor: Colors.white,
              ),
            ],
          ),
          centerTitle: true,
          actions: const [LogoutButton()],
        ),
        body: const TicketQueueView(),
      ),
    );
  }
}