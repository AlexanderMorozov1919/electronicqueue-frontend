part of 'schedule_widget.dart';

class ScheduleCard extends StatelessWidget {
  final String time;
  final String status;
  final AppTheme appTheme;
  final int? cabinet;

  const ScheduleCard({
    super.key,
    required this.appTheme,
    required this.status,
    required this.time,
    this.cabinet,
  });

  // Определяет цвет фона в зависимости от статуса
  Color _getStatusColor() {
    final statusColors = appTheme.getStatusColors();
    switch (status) {
      case 'busy':
        return statusColors['emergency']!; // Красный
      case 'free':
        return statusColors['completed']!; // Зелёный
      case 'unavailable':
      default:
        return statusColors['stopped']!; // Серый
    }
  }

  // Словарь для отображения статусов на русском языке
  static const Map<String, String> statusToRussian = {
    'busy': 'Занято',
    'free': 'Свободно',
    'unavailable': 'Недоступно',
  };

  @override
  Widget build(BuildContext context) {
    // Стиль текста - всегда черный, как вы и просили
    final textStyle =
        Theme.of(context).textTheme.bodySmall?.copyWith(color: appTheme.primaryColor);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(), // Цвет фона по статусу
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Левая часть: время и номер кабинета
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time, style: textStyle),
                  if (cabinet != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text('Кабинет: $cabinet', style: textStyle),
                    ),
                ],
              ),
              // Правая часть: статус на русском
              Text(
                statusToRussian[status] ?? '',
                style: textStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}