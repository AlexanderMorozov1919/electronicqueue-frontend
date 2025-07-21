part of 'schedule_widget.dart';

class ScheduleHead extends StatelessWidget {
  final AppTheme appTheme;
  final int recordsNum;
  final DateTime currentDate;
  final ScheduleFilter filter;
  final void Function() onFilter;
  final void Function(DateTime date) onChangeDate;
  final void Function(String filterType, String value) addFilter;
  final VoidCallback onToogleFilter;

  ScheduleHead({
    required this.appTheme,
    required this.currentDate,
    required this.onChangeDate,
    required this.onFilter,
    required this.recordsNum,
    required this.addFilter,
    required this.onToogleFilter,
    required this.filter,
  });

  String _formatDateTime(DateTime date) {
    final dateFormatter = DateFormat('dd.MM.yyyy, EEEE', 'ru');
    final timeFormatter = DateFormat('HH:mm:ss');
    
    final formattedDate = dateFormatter.format(date);
    final formattedTime = timeFormatter.format(DateTime.now());
    
    return "$formattedDate, $formattedTime";
  }

  Widget _buildDateBlock(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      children: [
        // Обновляется каждую секунду
        StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 1)),
          builder: (context, snapshot) {
            return Text(
              _formatDateTime(currentDate),
              style: Theme.of(context).textTheme.headlineSmall,
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDateBlock(context),
        ],
      ),
    );
  }
}