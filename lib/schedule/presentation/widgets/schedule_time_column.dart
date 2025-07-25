part of 'schedule_widget.dart';

class ScheduleTimeColumn extends StatelessWidget {
  final List<TimePoint> timePoints;
  final double sectionHeight;
  final AppTheme appTheme;

  ScheduleTimeColumn({
    required this.appTheme,
    required this.sectionHeight,
    required this.timePoints,
  });

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat('HH:mm');
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          const SizedBox(
            height: 119,
          ),
          for (TimePoint point in timePoints) ...[
            Container(
              height: sectionHeight,
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
          ]
        ],
      ),
    );
  }
}
