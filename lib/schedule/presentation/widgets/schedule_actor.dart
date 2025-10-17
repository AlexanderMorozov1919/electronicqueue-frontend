part of 'schedule_widget.dart';

class ScheduleActor extends StatelessWidget {
  final AppTheme appTheme;
  final StatefulNavigationShell? navigationShell;
  final int actorId;
  final String employeeName;
  final String equipmentName;
  final int? cabinet;

  const ScheduleActor({
    super.key,
    required this.actorId,
    required this.appTheme,
    required this.employeeName,
    required this.equipmentName,
    this.cabinet,
    this.navigationShell,
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
            // --- ИЗМЕНЕНИЯ ---
            softWrap: true, // Разрешаем перенос текста
            // overflow убран, чтобы текст не обрезался
            // -----------------
          ),
          const SizedBox(height: 4),
          Text(
            equipmentName,
            style: Theme.of(context).textTheme.bodyMedium,
            // --- ИЗМЕНЕНИЯ ---
            softWrap: true, // Разрешаем перенос текста
            // overflow убран, чтобы текст не обрезался
            // -----------------
          ),
          const SizedBox(height: 4),
          if (cabinet != null)
            Text(
              'Кабинет: $cabinet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ), 
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
        ],
      ),
    );
  }
}