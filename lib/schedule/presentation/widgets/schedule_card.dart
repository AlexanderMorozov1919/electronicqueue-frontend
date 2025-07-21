part of 'schedule_widget.dart';

class DisabledScheduleCard extends StatelessWidget {
  final AppTheme appTheme;
  final String time;

  DisabledScheduleCard({
    required this.appTheme,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        width: 450,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: appTheme.getMenuColors()['menuIconColor'],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: appTheme.primaryCardColor),
              ),
              Text(
                'Нет записи',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: appTheme.primaryCardColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VoidScheduleCard extends StatefulWidget {
  final AppTheme appTheme;
  final String time;
  final int equipmentId;
  final String equipmentName;
  final DateTime currentDate;
  final DateTime recordDate;
  final int employeeid;
  final String employeeName;
  final DateTime startTime;
  final DateTime endTime;

  const VoidScheduleCard({
    super.key,
    required this.appTheme,
    required this.time,
    required this.currentDate,
    required this.recordDate,
    required this.equipmentId,
    required this.equipmentName,
    required this.employeeid,
    required this.employeeName,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<VoidScheduleCard> createState() => _VoidScheduleCardState();
}

class _VoidScheduleCardState extends State<VoidScheduleCard> {
  bool _isHovered = false;
  bool _hasBorder = false;

  void _handleSingleTap() {
    setState(() {
      _hasBorder = !_hasBorder;
    });
  }

  void _handleDoubleTap() {
    GoRouter.of(context).push('/production-tasks/detail/new', extra: {
      'equipmentId': widget.equipmentId,
      'equipmentName': widget.equipmentName,
      'employeeId': widget.employeeid,
      'employeeName': widget.employeeName,
      'recordDate': widget.recordDate,
      'startTime': widget.startTime,
      'endTime': widget.endTime,
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _handleSingleTap();
        },
        onDoubleTap: () {
          _handleDoubleTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          transform: Matrix4.diagonal3Values(
            _isHovered ? 1.02 : 1.0,
            _isHovered ? 1.02 : 1.0,
            1.0,
          ),
          transformAlignment: Alignment.center,
          child: IntrinsicHeight(
            child: Container(
              width: 450,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: widget.appTheme.getAppColors()['primaryCard'],
                borderRadius: BorderRadius.circular(12),
                border: _hasBorder
                    ? Border.all(
                        color: widget.appTheme
                                .getMenuColors()['menuItemActiveColor'] ??
                            Colors.transparent,
                        width: 1.0,
                      )
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.time,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScheduleCard extends StatefulWidget {
  final int recordId;
  final String time;
  final String status;
  final AppTheme appTheme;
  final int actorId;
  final DateTime date;
  

  const ScheduleCard({
    super.key,
    required this.appTheme,
    required this.recordId,
    required this.status,
    required this.time,
    required this.actorId,
    required this.date,
  });

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  bool _isHovered = false;
  bool _hasBorder = false;

  Color _getStatusColor() {
    final statusColors = widget.appTheme.getStatusColors();
    switch(widget.status) {
      case 'busy': return statusColors['emergency']!; // Красный
      case 'free': return statusColors['completed']!; // Зеленый
      case 'unavailable': 
      default: return statusColors['stopped']!; // Серый
    }
  }

  final Map<String, String> statusToColor = {
    'created': 'created',
    'inProgress': 'inProgress',
    'inProgressNoDeviations': 'inProgressNoDeviations',
    'inProgressWithDeviations': 'inProgressWithDeviations',
    'emergency': 'emergency',
    'error': 'error',
    'stopped': 'stopped',
    'completed': 'completed',
    'cancelled': 'cancelled',
    'unknown': 'unknown',
    'busy': 'busy',
    'free': 'free',
    'unavailable': 'unavailable',
  };

  final Map<String, String> statusToRussian = {
    'created': 'Создано',
    'inProgress': 'В процессе',
    'inProgressNoDeviations': 'Без отклонений',
    'inProgressWithDeviations': 'С отклонениями',
    'emergency': 'Экстренно',
    'error': 'Ошибка',
    'stopped': 'Остановлено',
    'completed': 'Завершено',
    'cancelled': 'Отменено',
    'unknown': 'Неизвестно',
    'busy': 'Занято',
    'free': 'Свободно',
    'unavailable': 'Не доступно',
  };

  void _handleSingleTap() {
    setState(() {
      _hasBorder = !_hasBorder;
    });
  }

  void _handleDoubleTap() {
    GoRouter.of(context).push('/production-tasks/detail/${widget.recordId}');
  }

  TextStyle _getTextStyle(BuildContext context) {
    return widget.status != 'missed'
        ? Theme.of(context).textTheme.bodySmall!
        : TextStyle(
            color: widget.appTheme.primaryCardColor,
            fontFamily: 'Manrope',
            fontSize: 14,
            height: 1.6,
            fontWeight: FontWeight.w400,
          );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _handleSingleTap();
          },
          onDoubleTap: () {
            _handleDoubleTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform: Matrix4.diagonal3Values(
              _isHovered ? 1.02 : 1.0,
              _isHovered ? 1.02 : 1.0,
              1.0,
            ),
            transformAlignment: Alignment.center,
            constraints: BoxConstraints(
              minHeight: 0,
              maxHeight: double.infinity,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
            color: _getStatusColor(), // Используем новый метод
            borderRadius: BorderRadius.circular(12),
            border: _hasBorder
                ? Border.all(
                    color: widget.appTheme
                            .getMenuColors()['menuItemActiveColor'] ??
                        Colors.transparent,
                    width: 1.0,
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.time, style: _getTextStyle(context)),
                  Text(
                    statusToRussian[widget.status] ?? 'Неизвестно',
                    style: _getTextStyle(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
