part of 'schedule_widget.dart';

// 1. Вспомогательный класс
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
    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }

  List<Widget> _buildCards() {
    final dateOnly = date.split('T').first;
    final List<_DisplayBlock> displayBlocks = [];

    final sortedSlots = List<TimeSlotModel>.from(doctorSchedule.slots)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    // Шаг 1: Группировка последовательных слотов
    for (final slot in sortedSlots) {
      try {
        final slotStart = DateTime.parse('${dateOnly}T${slot.startTime}');
        final slotEnd = DateTime.parse('${dateOnly}T${slot.endTime}');
        final status = slot.isAvailable ? 'free' : 'busy';

        if (displayBlocks.isNotEmpty) {
          final lastBlock = displayBlocks.last;
          if (lastBlock.endTime.isAtSameMomentAs(slotStart) &&
              lastBlock.status == status &&
              lastBlock.cabinet == slot.cabinet) {
            displayBlocks[displayBlocks.length - 1] = _DisplayBlock(
              startTime: lastBlock.startTime,
              endTime: slotEnd,
              status: status,
              cabinet: slot.cabinet,
            );
            continue;
          }
        }
        displayBlocks.add(_DisplayBlock(
          startTime: slotStart,
          endTime: slotEnd,
          status: status,
          cabinet: slot.cabinet,
        ));
      } catch (e) {
        print("Ошибка парсинга времени слота: $e");
        continue;
      }
    }

    // Шаг 2: Заполнение "дыр"
    final List<_DisplayBlock> finalBlocks = [];
    if (timePoints.isEmpty) return [];

    final overallStartTime = timePoints.first.time;
    final overallEndTime = timePoints.last.time;
    DateTime currentTime = overallStartTime;

    for (final block in displayBlocks) {
      if (block.endTime.isBefore(overallStartTime) || block.startTime.isAfter(overallEndTime)) continue;
      
      DateTime effectiveBlockStart = block.startTime.isBefore(overallStartTime) ? overallStartTime : block.startTime;
      DateTime effectiveBlockEnd = block.endTime.isAfter(overallEndTime) ? overallEndTime : block.endTime;
      
      if (currentTime.isBefore(effectiveBlockStart)) {
        finalBlocks.add(_DisplayBlock(
            startTime: currentTime, endTime: effectiveBlockStart, status: 'free', cabinet: null));
      }
      finalBlocks.add(_DisplayBlock(
          startTime: effectiveBlockStart, endTime: effectiveBlockEnd, status: block.status, cabinet: block.cabinet));
      currentTime = effectiveBlockEnd;
    }

    if (currentTime.isBefore(overallEndTime)) {
      finalBlocks
          .add(_DisplayBlock(startTime: currentTime, endTime: overallEndTime, status: 'free', cabinet: null));
    }
    
    if (finalBlocks.isEmpty && overallStartTime.isBefore(overallEndTime)) {
        finalBlocks.add(_DisplayBlock(
          startTime: overallStartTime,
          endTime: overallEndTime,
          status: 'free',
          cabinet: null,
        ));
    }

    // Шаг 3: Создание виджетов
    final List<Widget> cards = [];
    final double heightPerMinute = sectionHeight / 30.0;
    const double verticalGap = 4.0;

    for (final block in finalBlocks) {
      final durationInMinutes = block.endTime.difference(block.startTime).inMinutes;
      if (durationInMinutes <= 0) continue;

      final totalAllocatedHeight = durationInMinutes * heightPerMinute;
      final cardHeight = totalAllocatedHeight - verticalGap;

      if (cardHeight <= 0) continue;

      // --- ИЗМЕНЕНИЕ: Логика размера шрифта удалена, осталась только логика отступов ---
      final cardPadding = durationInMinutes <= 10
          ? const EdgeInsets.symmetric(vertical: 1, horizontal: 12) 
          : const EdgeInsets.symmetric(vertical: 4, horizontal: 12); 

      cards.add(
        SizedBox(
          height: totalAllocatedHeight,
          child: Padding(
            padding: EdgeInsets.fromLTRB(5, 0, 5, verticalGap),
            child: ScheduleCard(
              key: ValueKey('${block.status}-${doctorSchedule.id}-${block.startTime.toIso8601String()}'),
              appTheme: appTheme,
              status: block.status,
              time: _formatTimeRange(block.startTime, block.endTime),
              padding: cardPadding,
            ),
          ),
        ),
      );
    }
    return cards;
  }
  
  List<Widget> _buildScheduleTable() {
    List<Widget> table = [];
    if(timePoints.length < 2) return table;

    final double sectionHeight = 60;
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