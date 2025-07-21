part of 'schedule_widget.dart';

class ScheduleInfoCard extends StatelessWidget {
  final AppTheme appTheme;
  final String patientFullname;
  final String date;
  final String time;
  final String? doctor;
  final String? room;
  final String service;

  ScheduleInfoCard({
    required this.date,
    this.doctor,
    required this.patientFullname,
    this.room,
    required this.time,
    required this.appTheme,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 348,
      //height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appTheme.primaryCardColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            patientFullname,
            style: Theme.of(context).textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 8,
            children: [
              Text(date, style: Theme.of(context).textTheme.bodySmall),
              SizedBox(
                width: 4,
                height: 4,
                child: SvgPicture.asset(
                  'assets/icons/ellipse.svg',
                  width: 4,
                  height: 4,
                ),
              ),
              Text(time, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          if (doctor != null || room != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                if (doctor != null) ...[
                  LimitedBox(
                    maxWidth: 176,
                    child: Text(
                      'Врач: $doctor',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ],
                if (doctor != null && room != null) ...[
                  SizedBox(
                    width: 4,
                    height: 4,
                    child: SvgPicture.asset(
                      'assets/icons/ellipse.svg',
                      width: 4,
                      height: 4,
                    ),
                  ),
                ],
                if (room != null) ...[
                  LimitedBox(
                    maxWidth: 122,
                    child: Text(
                      room ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ]
              ],
            ),
          ],
          Text(
            service,
            style: Theme.of(context).textTheme.labelLarge,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ],
      ),
    );
  }
}
