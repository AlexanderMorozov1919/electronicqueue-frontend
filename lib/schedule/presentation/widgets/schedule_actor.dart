part of 'schedule_widget.dart';

class ScheduleActor extends StatelessWidget {
  final AppTheme appTheme;
  final StatefulNavigationShell? navigationShell;
  final int actorId;
  final String employeeName;
  final String equipmentName;
  final String branchName;

  ScheduleActor({
    required this.actorId,
    required this.appTheme,
    required this.employeeName,
    required this.equipmentName,
    required this.branchName,
    this.navigationShell = null,
  });
    

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            employeeName,
            style: Theme.of(context).textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
          const SizedBox(height: 4),
          Text(
            equipmentName,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
          const SizedBox(height: 4),
          Text(
            branchName,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ],
      ),
    );
  }
}
