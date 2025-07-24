part of 'schedule_widget.dart';

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

  List<Widget> _buildCards() {
    List<Widget> cards = [];
    final dateOnly = date.split('T').first;

    for (int i = 0; i < timePoints.length - 1; i++) {
      final intervalStart = timePoints[i].time;
      final intervalEnd = timePoints[i + 1].time;

      TimeSlotModel? matchingSlot;
      for (final slot in doctorSchedule.slots.cast<TimeSlotModel>()) {
        final slotStartDateTime =
            DateTime.parse('${dateOnly}T${slot.startTime}');
        if (slotStartDateTime.isAtSameMomentAs(intervalStart)) {
          matchingSlot = slot;
          break;
        }
      }

      Widget card;
      if (matchingSlot != null) {
        // Если для интервала есть слот от сервера
        final slotStartDateTime =
            DateTime.parse('${dateOnly}T${matchingSlot.startTime}');
        final slotEndDateTime =
            DateTime.parse('${dateOnly}T${matchingSlot.endTime}');
        
        // Создаем единую карточку с нужным статусом
        card = ScheduleCard(
          key: ValueKey(
              '${matchingSlot.isAvailable ? 'free' : 'busy'}-${doctorSchedule.id}-${matchingSlot.startTime}'),
          appTheme: appTheme,
          status: matchingSlot.isAvailable ? 'free' : 'busy',
          time: _formatTimeRange(slotStartDateTime, slotEndDateTime),
          cabinet: matchingSlot.cabinet,
        );
      } else {
        // Если для интервала нет данных - считаем его недоступным
        card = ScheduleCard(
          key: ValueKey(
              'unavailable-${doctorSchedule.id}-${intervalStart.toIso8601String()}'),
          appTheme: appTheme,
          status: 'unavailable',
          time: _formatTimeRange(intervalStart, intervalEnd),
          cabinet: null,
        );
      }

      cards.add(Container(
        height: sectionHeight,
        padding: const EdgeInsets.only(top: 1, bottom: 3, right: 5, left: 5),
        child: card,
      ));
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