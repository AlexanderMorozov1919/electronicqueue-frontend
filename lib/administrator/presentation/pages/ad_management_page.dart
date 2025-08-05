import 'package:elqueue/administrator/presentation/widgets/ad/ad_card_widget.dart';
import 'package:elqueue/administrator/presentation/widgets/ad/ad_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/ad/ad_bloc.dart';

class AdManagementPage extends StatefulWidget {
  const AdManagementPage({super.key});

  @override
  State<AdManagementPage> createState() => _AdManagementPageState();
}

class _AdManagementPageState extends State<AdManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdBloc>().add(LoadAds());
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AdBloc>(),
        child: const AdEditDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление рекламой'),
      ),
      body: BlocConsumer<AdBloc, AdState>(
        listener: (context, state) {
          if (state is AdError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is AdLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdLoaded) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.ads.length,
              itemBuilder: (context, index) {
                return AdCardWidget(ad: state.ads[index]);
              },
            );
          }
          return const Center(child: Text('Нет данных для отображения'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEditDialog,
        tooltip: 'Добавить рекламу',
        child: const Icon(Icons.add),
      ),
    );
  }
}