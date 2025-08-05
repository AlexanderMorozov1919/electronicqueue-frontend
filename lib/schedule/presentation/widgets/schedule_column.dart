part of 'schedule_widget.dart';

// 1. ДОБАВЬТЕ ЭТОТ ВСПОМОГАТЕЛЬНЫЙ КЛАСС В НАЧАЛЕ ФАЙЛА
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

  const ScheduleColumn({
    super.key,
    required this.appTheme,
    required this.doctorSchedule,
    required this.date,
    required this.sectionHeight,
    required this.timePoints,
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

  // 2. ПОЛНОСТЬЮ ЗАМЕНИТЕ СТАРЫЙ МЕТОД _buildCards НА ЭТОТ
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

    final overallStartTime = timePoints.first.time;
    final overallEndTime = timePoints.last.time;
    DateTime currentTime = overallStartTime;

    for (final block in displayBlocks) {
      // Если есть промежуток до начала текущего блока, создаем "недоступный" блок
      if (currentTime.isBefore(block.startTime)) {
        finalBlocks.add(_DisplayBlock(
          startTime: currentTime,
          endTime: block.startTime,
          status: 'unavailable',
          cabinet: null,
        ));
      }
      // Добавляем сам блок (реальный, сгруппированный)
      finalBlocks.add(block);
      // Сдвигаем указатель времени на конец добавленного блока
      currentTime = block.endTime;
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
    
    // Обрабатываем случай, когда у врача вообще нет слотов в расписании
    if (sortedSlots.isEmpty && overallStartTime.isBefore(overallEndTime)) {
      finalBlocks.add(_DisplayBlock(
        startTime: overallStartTime,
        endTime: overallEndTime,
        status: 'unavailable',
        cabinet: null,
      ));
    }

    // Шаг 3: Создаем виджеты из финального списка блоков
    final List<Widget> cards = [];
    // Высота одной минуты на экране (исходя из того, что `sectionHeight` - это 30 минут)
    final double heightPerMinute = sectionHeight / 30.0; 

    for (final block in finalBlocks) {
      final durationInMinutes = block.endTime.difference(block.startTime).inMinutes;
      if (durationInMinutes <= 0) continue; // Пропускаем блоки с нулевой или отрицательной длиной

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
            cabinet: block.cabinet,
          ),
        ),
      );
    }
    return cards;
  }

  List<Widget> _buildScheduleTable() {
    List<Widget> table = [];

    for (int i = 0; i < timePoints.length - 1; i++) {
      table.add(Container(
        width: 280,
        height: sectionHeight,
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            right: BorderSide(
              width: 1,
              color: appTheme.scheduleTableColor,
            ),
            bottom: (timePoints[i + 1].isAxis)
                ? BorderSide(
                    width: 1,
                    color: appTheme.scheduleTableColor,
                  )
                : BorderSide.none,
          ),
        ),
      ));
    }
    return table;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(0),
            width: 280,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                right: BorderSide(
                  width: 1,
                  color: appTheme.scheduleTableColor,
                ),
                bottom: BorderSide(
                  width: 1,
                  color: appTheme.scheduleTableColor,
                ),
              ),
            ),
            child: ScheduleActor(
              actorId: doctorSchedule.id,
              appTheme: appTheme,
              employeeName: doctorSchedule.fullName,
              equipmentName: doctorSchedule.specialization,
              branchName: '', // No branch name in model
            ),
          ),
          Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Column(
                children: _buildScheduleTable(),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  width: 280,
                  height: sectionHeight * (timePoints.length - 1),
                  child: Column(
                    key: ValueKey('cards-col-${doctorSchedule.id}'),
                    children: _buildCards(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}