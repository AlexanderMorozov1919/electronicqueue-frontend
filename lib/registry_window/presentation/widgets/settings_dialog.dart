import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/settings_bloc.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadSettings());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.saveSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Приоритеты успешно сохранены'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Настройка приоритетов окна'),
          content: SizedBox(
            width: 400,
            child: state.isLoading && state.allServices.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(context, state),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () => context.read<SettingsBloc>().add(SavePriorities()),
              child: state.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, SettingsState state) {
    if (state.allServices.isEmpty) {
      return const Center(child: Text('Нет доступных категорий для настройки.'));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.allServices.length,
            itemBuilder: (context, index) {
              final service = state.allServices[index];
              final isSelected = state.selectedServiceIds.contains(service.id);
              return CheckboxListTile(
                title: Text(service.name),
                value: isSelected,
                onChanged: (bool? value) {
                  context.read<SettingsBloc>().add(TogglePriority(service.id));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}