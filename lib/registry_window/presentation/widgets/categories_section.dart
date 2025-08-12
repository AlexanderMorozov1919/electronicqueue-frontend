import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/ticket_category.dart';
import '../../domain/entities/service_entity.dart';
import '../blocs/ticket/ticket_bloc.dart';
import '../blocs/ticket/ticket_event.dart';
import '../blocs/ticket/ticket_state.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  TicketCategory _getCategoryFromLetter(String letter) {
    switch (letter) {
      case 'A':
        return TicketCategory.makeAppointment;
      case 'B':
        return TicketCategory.byAppointment;
      case 'C':
        return TicketCategory.tests;
      case 'D':
        return TicketCategory.other;
      default:
        return TicketCategory.all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Категории',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocSelector<TicketBloc, TicketState,
                  (TicketCategory?, List<ServiceEntity>)>(
                selector: (state) =>
                    (state.selectedCategory, state.availableCategories),
                builder: (context, data) {
                  final selectedCategory = data.$1;
                  final availableCategories = data.$2;

                  if (availableCategories.isEmpty) {
                    return const Center(child: Text("Нет доступных категорий."));
                  }
                  
                  final allCategoryService = ServiceEntity(id: -1, name: 'Все категории', letter: 'ALL');
                  final displayList = [allCategoryService, ...availableCategories];


                  // ЗАМЕНА Column НА ListView.builder для скроллинга
                  return ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final service = displayList[index];
                      final category = (service.letter == 'ALL')
                          ? TicketCategory.all
                          : _getCategoryFromLetter(service.letter);
                          
                      final isSelected = category == selectedCategory;

                      // Убрана обертка Expanded
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                            elevation: MaterialStateProperty.all(0),
                            alignment: Alignment.centerLeft,
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 16.0),
                            ),
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                                    (states) {
                              if (isSelected) {
                                return const Color(0xFF415BE7);
                              }
                              return Colors.white;
                            }),
                            foregroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                                    (states) {
                              if (isSelected) {
                                return Colors.white;
                              }
                              return Colors.black;
                            }),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color?>(
                                    (states) {
                              if (isSelected) return null;
                              if (states.contains(MaterialState.pressed)) {
                                return const Color(0xFF415BE7)
                                    .withOpacity(0.12);
                              }
                              if (states.contains(MaterialState.hovered)) {
                                return Colors.grey.withOpacity(0.1);
                              }
                              return null;
                            }),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            textStyle: MaterialStateProperty.all(
                              const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onPressed: () {
                            context
                                .read<TicketBloc>()
                                .add(LoadTicketsByCategoryEvent(category));
                          },
                          child: Text(service.name),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}