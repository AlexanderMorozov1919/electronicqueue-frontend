import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/settings_bloc.dart';

class ServerSettingsPage extends StatefulWidget {
  const ServerSettingsPage({super.key});

  @override
  State<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends State<ServerSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadProcesses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки сервера'),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.processes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: state.processes.length,
            itemBuilder: (context, index) {
              final process = state.processes[index];
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
          );
        },
      ),
    );
  }
}