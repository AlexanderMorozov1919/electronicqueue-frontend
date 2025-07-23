import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/waiting_screen_entity.dart';
import '../blocs/waiting_screen_bloc.dart';
import '../blocs/waiting_screen_event.dart';
import '../blocs/waiting_screen_state.dart';

class WaitingScreenPage extends StatefulWidget {
  final int cabinetNumber;

  const WaitingScreenPage({super.key, required this.cabinetNumber});

  @override
  State<WaitingScreenPage> createState() => _WaitingScreenPageState();
}

class _WaitingScreenPageState extends State<WaitingScreenPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<WaitingScreenBloc>()
          .add(LoadWaitingScreen(cabinetNumber: widget.cabinetNumber));
    });
  }

  String _shortenName(String fullName) {
    if (fullName.trim().isEmpty || fullName == 'Неизвестный пациент') {
      return 'Неизвестный пациент';
    }
    final parts = fullName.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length < 2) {
      return fullName;
    }

    final lastName = parts[0];
    final firstNameInitial = '${parts[1][0]}.';

    if (parts.length < 3) {
      return '$lastName $firstNameInitial';
    }

    final middleNameInitial = '${parts[2][0]}.';
    return '$lastName $firstNameInitial $middleNameInitial';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocBuilder<WaitingScreenBloc, WaitingScreenState>(
        builder: (context, state) {
          if (state is WaitingScreenError) {
            return _buildError(state.message);
          }

          if (state is DoctorQueueLoaded) {
            final entity = state.queueEntity;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildModernHeader(
                      entity.doctorName,
                      entity.doctorSpecialty,
                      entity.cabinetNumber,
                      entity.doctorStatus),
                  const SizedBox(height: 16),
                  _buildQueueHeader(),
                  entity.queue.isEmpty
                      ? _buildEmptyQueue()
                      : _buildModernQueueList(entity.queue),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
          
          // Для состояний WaitingScreenInitial и WaitingScreenLoading
          // показываем каркас страницы с индикатором загрузки в области очереди.
          // В widget.cabinetNumber уже есть нужный номер.
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildModernHeader("", "", widget.cabinetNumber, "неактивен"),
                const SizedBox(height: 16),
                _buildQueueHeader(),
                _buildQueueLoading(),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQueueLoading() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000), // Colors.black.withOpacity(0.05)
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 48.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  color: Color(0xFF1B4193),
                  strokeWidth: 4,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Загрузка очереди...',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Остальные методы (_buildError, _buildModernHeader и т.д.) остаются без изменений
  // ... (здесь идет остальной код виджета, который не менялся)

  Widget _buildError(String message) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0x1A000000), // Colors.black.withOpacity(0.1)
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 16),
              Text(
                'Произошла ошибка',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Перезагрузка через 5 секунд...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(String doctorName, String specialty, int cabinetNumber, String doctorStatus) {
    final bool isOnBreak = doctorStatus == 'перерыв';
    final String headerText =
        isOnBreak ? 'КАБИНЕТ $cabinetNumber - ПЕРЕРЫВ' : 'КАБИНЕТ $cabinetNumber';
    final List<Color> gradientColors = isOnBreak
        ? [const Color(0xFFF97316), const Color(0xFFEA580C), const Color(0xFFD97706)]
        : [const Color(0xFF1B4193), const Color(0xFF2563EB), const Color(0xFF3B82F6)];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF), // Colors.white.withOpacity(0.1)
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0x33FFFFFF), // Colors.white.withOpacity(0.2)
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOnBreak ? Icons.coffee_rounded : Icons.meeting_room,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      headerText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (doctorName.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0x0DFFFFFF), // Colors.white.withOpacity(0.05)
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            doctorName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 42,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      specialty,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 36,
                        color: Color(0xE6FFFFFF), // Colors.white.withOpacity(0.9)
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQueueHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF374151), Color(0xFF4B5563)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000), // Colors.black.withOpacity(0.1)
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Время',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Талон',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'Пациент',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Статус',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQueue() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000), // Colors.black.withOpacity(0.05)
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 48.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available,
                size: 80,
                color: Color(0xFF9CA3AF),
              ),
              SizedBox(height: 16),
              Text(
                'Очередь пуста',
                style: TextStyle(
                  fontSize: 36,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Нет пациентов в очереди',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFFD1D5DB),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernQueueList(List<DoctorQueueTicketEntity> queue) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000), // Colors.black.withOpacity(0.05)
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(queue.length, (index) {
            final item = queue[index];
            final bool isOnAppointment = item.status == 'на_приеме';
            return _buildModernQueueItem(item, isOnAppointment);
          }),
        ),
      ),
    );
  }

  Widget _buildModernQueueItem(DoctorQueueTicketEntity item, bool isOnAppointment) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: isOnAppointment
                ? const Color(0xFFDC2626)
                : const Color(0xFF059669),
            width: 4,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 20,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.startTime,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF8FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.confirmation_number,
                    size: 20,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.ticketNumber,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 24,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _shortenName(item.patientFullName),
                    style: const TextStyle(
                      fontSize: 28,
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isOnAppointment
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                      )
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF059669), Color(0xFF047857)],
                      ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isOnAppointment
                        ? const Color(0x4DDC2626) // red with 0.3 opacity
                        : const Color(0x4D059669), // green with 0.3 opacity
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOnAppointment ? Icons.medical_services : Icons.schedule,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isOnAppointment ? 'НА ПРИЕМЕ' : 'ОЖИДАЕТ',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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