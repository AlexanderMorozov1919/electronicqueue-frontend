import 'package:elqueue/administrator/presentation/blocs/ad/ad_bloc.dart';
import 'package:elqueue/administrator/presentation/pages/ad_management_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/settings/settings_bloc.dart';
import 'auth_page.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is! AuthSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Панель администратора'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Выйти',
              onPressed: () {
                context.read<AuthBloc>().add(const LogoutRequested());
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Добро пожаловать!',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text('Настройки сервера'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: BlocProvider.of<SettingsBloc>(context),
                      child: const ServerSettingsDialog(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // --- НОВАЯ КНОПКА УПРАВЛЕНИЯ РЕКЛАМОЙ ---
              ElevatedButton.icon(
                icon: const Icon(Icons.ad_units),
                label: const Text('Управление рекламой'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: BlocProvider.of<AdBloc>(context),
                        child: const AdManagementPage(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServerSettingsDialog extends StatefulWidget {
  const ServerSettingsDialog({super.key});

  @override
  State<ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<ServerSettingsDialog> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadProcesses());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final sortedProcesses = List.from(state.processes)
          ..sort((a, b) => a.displayName.compareTo(b.displayName));

        return AlertDialog(
          title: const Text('Настройки сервера'),
          content: SizedBox(
            width: 500,
            child: (state.isLoading && state.processes.isEmpty)
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: sortedProcesses.length,
                    itemBuilder: (context, index) {
                      final process = sortedProcesses[index];
                      return SwitchListTile(
                        title: Text(process.displayName),
                        subtitle: Text(process.isEnabled ? 'Включен' : 'Отключен'),
                        value: process.isEnabled,
                        onChanged: (newValue) {
                          context.read<SettingsBloc>().add(ToggleProcess(
                                processName: process.name,
                                isEnabled: newValue,
                              ));
                        },
                      );
                    },
                  ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Закрыть'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}