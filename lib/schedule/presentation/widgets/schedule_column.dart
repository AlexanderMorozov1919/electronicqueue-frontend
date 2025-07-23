part of 'schedule_widget.dart';

class ScheduleColumn extends StatelessWidget {
  final Booking booking;
  final List<TimePoint> timePoints;
  final double sectionHeight;
  final AppTheme appTheme;
  ScheduleColumn({
    required this.appTheme,
    required this.booking,
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
    final DateTime now = DateTime.now(); 

    for (int i = 0; i < timePoints.length - 1; i++) {
      final slotStart = timePoints[i].time;
      final slotEnd = timePoints[i + 1].time;

      bool isBooked = booking.bookingEntities.any((entity) {
        return (slotStart.isBefore(entity.endTime) &&
                slotEnd.isAfter(entity.startTime)) ||
            slotStart.isAtSameMomentAs(entity.startTime);
      });

      String status;
      if (slotEnd.isBefore(now)) {
        status = 'unavailable';
      } else if (slotStart.isBefore(booking.startTime) ||
          slotEnd.isAfter(booking.endTime)) {
        status = 'unavailable';
      } else {
        status = isBooked ? 'busy' : 'free';
      }

      cards.add(Container(
        height: sectionHeight,
        padding: const EdgeInsets.only(top: 1, bottom: 3, right: 5, left: 5),
        child: ScheduleCard(
          appTheme: appTheme,
          recordId: isBooked
              ? booking.bookingEntities
                  .firstWhere((e) =>
                      (slotStart.isBefore(e.endTime) &&
                          slotEnd.isAfter(e.startTime)) ||
                      slotStart.isAtSameMomentAs(e.startTime))
                  .id
              : 0,
          status: status,
          time: _formatTimeRange(slotStart, slotEnd),
          actorId: booking.actor.equipmentId,
          date: slotStart,
        ),
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
              actorId: booking.actor.equipmentId,
              appTheme: appTheme,
              employeeName: booking.actor.employeeName,
              equipmentName: booking.actor.equipmentName,
              branchName: booking.actor.branchName,
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
                  height:
                      sectionHeight * timePoints.length, 
                  child: Column(
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
