import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/ticket_category.dart';
import '../blocs/ticket/ticket_bloc.dart';
import '../blocs/ticket/ticket_event.dart';
import '../blocs/ticket/ticket_state.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      // Убираем тень у самой карточки, чтобы кнопки выглядели "плоскими"
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
              child: BlocSelector<TicketBloc, TicketState, TicketCategory?>(
                selector: (state) => state.selectedCategory,
                builder: (context, selectedCategory) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: TicketCategory.values.map((category) {
                      final isSelected = category == selectedCategory;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ElevatedButton(
                            // *** НАЧАЛО ИЗМЕНЕНИЙ ***
                            // Используем конструктор ButtonStyle для тонкой настройки
                            style: ButtonStyle(
                              // Убираем тень для всех состояний
                              elevation: MaterialStateProperty.all(0),
                              // Выравниваем текст по левому краю
                              alignment: Alignment.centerLeft,
                              // Добавляем отступы
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                              // Устанавливаем основной цвет фона
                              backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                                // Если кнопка выбрана, она всегда синяя
                                if (isSelected) {
                                  return const Color(0xFF415BE7);
                                }
                                // В остальных случаях - белая
                                return Colors.white;
                              }),
                              // Устанавливаем цвет текста
                              foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                                // Если выбрана - белый, иначе - черный
                                if (isSelected) {
                                  return Colors.white;
                                }
                                return Colors.black;
                              }),
                              // Управляем цветом "наложения" для состояний наведения и нажатия
                              overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                                // Если кнопка уже выбрана, не меняем цвет при наведении/нажатии
                                if (isSelected) return null; 
                                // При нажатии - легкий синий оттенок
                                if (states.contains(MaterialState.pressed)) {
                                  return const Color(0xFF415BE7).withOpacity(0.12);
                                }
                                // При наведении - серый оттенок
                                if (states.contains(MaterialState.hovered)) {
                                  return Colors.grey.withOpacity(0.1);
                                }
                                return null; // нет эффекта в других случаях
                              }),
                              // Форма кнопки
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
                            // *** КОНЕЦ ИЗМЕНЕНИЙ ***
                            onPressed: () {
                              context.read<TicketBloc>().add(LoadTicketsByCategoryEvent(category));
                            },
                            child: Text(category.name),
                          ),
                        ),
                      );
                    }).toList(),
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