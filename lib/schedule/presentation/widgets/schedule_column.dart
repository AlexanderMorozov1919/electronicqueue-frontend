part of 'schedule_widget.dart';

// 1. Вспомогательный класс (без изменений)
class _DisplayBlock {
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final int? cabinet;

  _DisplayBlock({
    required this.startTime,
    required this.endTime,
    required this.status,
    this.cabinet,
  });
}

class ScheduleColumn extends StatelessWidget {
  final DoctorScheduleEntity doctorSchedule;
  final String date;
  final List<TimePoint> timePoints;
  final double sectionHeight;
  final AppTheme appTheme;
  final double width;

  const ScheduleColumn({
    super.key,
    required this.appTheme,
    required this.doctorSchedule,
    required this.date,
    required this.sectionHeight,
    required this.timePoints,
    required this.width,
  });

  String _formatTimeRange(DateTime startTime, DateTime endTime) {
    String formatTime(DateTime time) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      return '${twoDigits(time.hour)}:${twoDigits(time.minute)}';
    }

    String start = formatTime(startTime);
    String end = formatTime(endTime);

    return '$start - $end';
  }

  // 2. Метод _buildCards (без изменений в логике, но вызов ScheduleCard теперь проще)
  List<Widget> _buildCards() {
    final dateOnly = date.split('T').first;
    final List<_DisplayBlock> displayBlocks = [];

    // Сортируем слоты по времени начала для корректной группировки
    final sortedSlots = List<TimeSlotModel>.from(doctorSchedule.slots)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    // Шаг 1: Группируем последовательные слоты с одинаковым статусом и кабинетом
    for (final slot in sortedSlots) {
      final slotStart = DateTime.parse('${dateOnly}T${slot.startTime}');
      final slotEnd = DateTime.parse('${dateOnly}T${slot.endTime}');
      final status = slot.isAvailable ? 'free' : 'busy';

      if (displayBlocks.isNotEmpty) {
        final lastBlock = displayBlocks.last;
        // Проверяем, что слот идет сразу за предыдущим блоком и имеет тот же статус/кабинет
        if (lastBlock.endTime.isAtSameMomentAs(slotStart) &&
            lastBlock.status == status &&
            lastBlock.cabinet == slot.cabinet) {
          // Если да, то "склеиваем" их, обновляя время окончания последнего блока
          displayBlocks[displayBlocks.length - 1] = _DisplayBlock(
            startTime: lastBlock.startTime,
            endTime: slotEnd,
            status: status,
            cabinet: slot.cabinet,
          );
          continue; // Переходим к следующему слоту
        }
      }

      // Если слот не был склеен, добавляем его как новый блок
      displayBlocks.add(_DisplayBlock(
        startTime: slotStart,
        endTime: slotEnd,
        status: status,
        cabinet: slot.cabinet,
      ));
    }

    // Шаг 2: Заполняем "дыры" между блоками как недоступное время
    final List<_DisplayBlock> finalBlocks = [];
    if (timePoints.isEmpty) {
      return []; // Нечего отображать, если нет временной шкалы
    }

    // Используем время из переданных timePoints как границы
    final overallStartTime = timePoints.first.time;
    final overallEndTime = timePoints.last.time;
    DateTime currentTime = overallStartTime;

    for (final block in displayBlocks) {
      // Игнорируем блоки, которые полностью вне видимого диапазона
      if (block.endTime.isBefore(overallStartTime) || block.startTime.isAfter(overallEndTime)) {
        continue;
      }

      // Обрезаем блоки, которые частично выходят за границы
      DateTime effectiveBlockStart = block.startTime.isBefore(overallStartTime) ? overallStartTime : block.startTime;
      DateTime effectiveBlockEnd = block.endTime.isAfter(overallEndTime) ? overallEndTime : block.endTime;


      // Если есть промежуток до начала текущего блока, создаем "недоступный" блок
      if (currentTime.isBefore(effectiveBlockStart)) {
        finalBlocks.add(_DisplayBlock(
          startTime: currentTime,
          endTime: effectiveBlockStart,
          status: 'unavailable',
          cabinet: null,
        ));
      }
      // Добавляем сам блок (реальный, сгруппированный)
      finalBlocks.add(_DisplayBlock(
          startTime: effectiveBlockStart,
          endTime: effectiveBlockEnd,
          status: block.status,
          cabinet: block.cabinet,
        ));
      // Сдвигаем указатель времени на конец добавленного блока
      currentTime = effectiveBlockEnd;
    }

    // Заполняем оставшееся время до конца дня как "недоступное"
    if (currentTime.isBefore(overallEndTime)) {
      finalBlocks.add(_DisplayBlock(
        startTime: currentTime,
        endTime: overallEndTime,
        status: 'unavailable',
        cabinet: null,
      ));
    }
    
    // Обрабатываем случай, когда у врача вообще нет слотов в расписании на видимом участке
    if (finalBlocks.isEmpty && overallStartTime.isBefore(overallEndTime)) {
      finalBlocks.add(_DisplayBlock(
        startTime: overallStartTime,
        endTime: overallEndTime,
        status: 'unavailable',
        cabinet: null,
      ));
    }

    // Шаг 3: Создаем виджеты из финального списка блоков
    final List<Widget> cards = [];
    final double heightPerMinute = sectionHeight / 30.0; 

    for (final block in finalBlocks) {
      final durationInMinutes = block.endTime.difference(block.startTime).inMinutes;
      if (durationInMinutes <= 0) continue; 

      final cardHeight = durationInMinutes * heightPerMinute;

      cards.add(
        Container(
          height: cardHeight,
          padding: const EdgeInsets.only(top: 1, bottom: 3, right: 5, left: 5),
          child: ScheduleCard(
            key: ValueKey('${block.status}-${doctorSchedule.id}-${block.startTime.toIso8601String()}'),
            appTheme: appTheme,
            status: block.status,
            time: _formatTimeRange(block.startTime, block.endTime),
            // Кабинет больше не передается в ScheduleCard
          ),
        ),
      );
    }
    return cards;
  }

  // ИЗМЕНЕНИЕ: Убираем сетку
  List<Widget> _buildScheduleTable() {
    List<Widget> table = [];
    if(timePoints.length < 2) return table;

    // Высота одной секции (30 минут)
    final double sectionHeight = 60;
    // Общая высота контейнера на основе видимых временных точек
    final double totalHeight = sectionHeight * (timePoints.length-1);

    table.add(Container(
        width: width,
        height: totalHeight,
        padding: const EdgeInsets.all(0),
      ));
      
    return table;
  }

  @override
  Widget build(BuildContext context) {
    int? cabinet;
    for (final slot in doctorSchedule.slots) {
      if (slot.cabinet != null) {
        cabinet = slot.cabinet;
        break;
      }
    }

    return SizedBox(
      width: width,
      child: Column(
        children: [
          // --- ИЗМЕНЕНИЕ: Задаем явную высоту для шапки ---
          Container(
            height: 135,
            padding: const EdgeInsets.all(0),
            width: width,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: ScheduleActor(
              actorId: doctorSchedule.id,
              appTheme: appTheme,
              employeeName: doctorSchedule.fullName,
              equipmentName: doctorSchedule.specialization,
              cabinet: cabinet, 
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Column(
                    children: _buildScheduleTable(),
                  ),
                  Positioned.fill(
                    child: Column(
                      key: ValueKey('cards-col-${doctorSchedule.id}'),
                      children: _buildCards(),
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