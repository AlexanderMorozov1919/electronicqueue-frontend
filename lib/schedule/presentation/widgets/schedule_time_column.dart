part of 'schedule_widget.dart';

class ScheduleTimeColumn extends StatelessWidget {
  final List<TimePoint> timePoints;
  final double sectionHeight;
  final AppTheme appTheme;

  const ScheduleTimeColumn({
    super.key,
    required this.appTheme,
    required this.sectionHeight,
    required this.timePoints,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('HH:mm');
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          // 1. Контейнер-распорка, чтобы выровнять по высоте с шапкой врача
          const SizedBox(
            height: 135,
          ),
          // 2. Expanded занимает все оставшееся место
          Expanded(
            child: ClipRRect(
              // 3. Скругляем левый нижний угол
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
              ),
              child: Column(
                children: [
                  // 4. Генерируем временные метки
                  for (final point in timePoints)
                    // Пропускаем последнюю точку, чтобы избежать лишнего отступа внизу
                    if (point != timePoints.last)
                      Container(
                        height: sectionHeight,
                        padding: const EdgeInsets.only(right: 8.0), // Отступ справа от текста
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            formatter.format(point.time),
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                              color: point.isAxis
                                  ? appTheme.primaryColor
                                  : appTheme.textColor,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}