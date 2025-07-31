import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/waiting_screen_entity.dart';
import '../blocs/waiting_screen_bloc.dart';
import '../blocs/waiting_screen_event.dart';
import '../blocs/waiting_screen_state.dart';

// --- Константы для дизайна и верстки ---

const Size _kBaseTicketSize = Size(180, 80); // Теперь это и максимальный размер
const double _kSpacing = 16.0;
const double _kOuterPadding = 16.0;

/// Структура для хранения вычисленных параметров верстки
class _LayoutConfiguration {
  final int columnCount;
  final Size ticketSize;

  const _LayoutConfiguration({
    required this.columnCount,
    required this.ticketSize,
  });
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocBuilder<WaitingScreenBloc, WaitingScreenState>(
        builder: (context, state) {
          if (state is WaitingScreenError) {
            return _buildError(state.message);
          }

          if (state is DoctorQueueLoaded) {
            final entity = state.queueEntity;
            final inProgressTickets =
                entity.queue.where((t) => t.status == 'на_приеме').toList();
            final waitingTickets =
                entity.queue.where((t) => t.status != 'на_приеме').toList();

            return Column(
              children: [
                _buildNewHeader(
                  cabinetNumber: entity.cabinetNumber.toString(),
                  doctorName: entity.doctorName,
                  specialty: entity.doctorSpecialty,
                ),
                _buildQueueStatusHeader(),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTicketDisplayArea(
                          tickets: waitingTickets,
                          isWaiting: true,
                        ),
                      ),
                      Container(
                        width: 1,
                        color: const Color(0xFFE0E0E0),
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildTicketDisplayArea(
                          tickets: inProgressTickets,
                          isWaiting: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildNewHeader(
                cabinetNumber: widget.cabinetNumber.toString(),
                doctorName: "Загрузка...",
                specialty: "Пожалуйста, подождите",
              ),
              _buildQueueStatusHeader(),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF667EEA),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Финальная версия, использующая модель "ячейки" и ограничивающая максимальный размер.
  _LayoutConfiguration _calculateLayout(Size availableSize, int itemCount) {
    if (itemCount == 0 || availableSize.isEmpty) {
      return const _LayoutConfiguration(columnCount: 1, ticketSize: Size.zero);
    }

    _LayoutConfiguration? bestLayout;
    double maxArea = 0.0;
    final double baseAspectRatio = _kBaseTicketSize.aspectRatio;

    for (int cols = 1; cols <= itemCount; cols++) {
      final int rows = (itemCount / cols).ceil();
      const double safetyMargin = 0.01;

      final double totalHorizontalSpacing = (cols - 1) * _kSpacing;
      final double availableWidth = availableSize.width - totalHorizontalSpacing - safetyMargin;
      final double widthPerTicket = availableWidth / cols;
      
      final double availableHeight = availableSize.height - safetyMargin;
      final double heightPerCell = availableHeight / rows;
      final double heightPerTicket = heightPerCell - _kSpacing;

      if (widthPerTicket <= 0 || heightPerTicket <= 0) continue;
      
      double finalTicketWidth;
      double finalTicketHeight;
      
      if (widthPerTicket < heightPerTicket * baseAspectRatio) {
        finalTicketWidth = widthPerTicket;
        finalTicketHeight = finalTicketWidth / baseAspectRatio;
      } else {
        finalTicketHeight = heightPerTicket;
        finalTicketWidth = finalTicketHeight * baseAspectRatio;
      }

      // [НОВОЕ ИЗМЕНЕНИЕ] Применение максимального размера
      // Ограничиваем вычисленную ширину максимальным значением из константы.
      finalTicketWidth = min(finalTicketWidth, _kBaseTicketSize.width);
      // Пересчитываем высоту, чтобы сохранить пропорции после возможного ограничения ширины.
      finalTicketHeight = finalTicketWidth / baseAspectRatio;
      
      final double currentArea = finalTicketWidth * finalTicketHeight;
      if (currentArea > maxArea) {
        maxArea = currentArea;
        bestLayout = _LayoutConfiguration(
          columnCount: cols,
          ticketSize: Size(finalTicketWidth, finalTicketHeight),
        );
      }
    }

    return bestLayout ?? const _LayoutConfiguration(columnCount: 1, ticketSize: Size.zero);
  }

  /// Отображает талоны, используя паттерн "мягкой рамки".
  Widget _buildTicketDisplayArea({
    required List<DoctorQueueTicketEntity> tickets,
    required bool isWaiting,
  }) {
    return Padding(
      padding: const EdgeInsets.all(_kOuterPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (tickets.isEmpty) {
            return Center(
              child: Text(
                isWaiting ? 'Нет пациентов в очереди' : 'Нет пациентов на приеме',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          }
          
          final layout = _calculateLayout(constraints.biggest, tickets.length);
          if (layout.ticketSize.isEmpty || layout.ticketSize.width <= 0) {
            return const SizedBox.shrink();
          }

          final int columnCount = layout.columnCount;
          final int itemsPerColumn = (tickets.length / columnCount).ceil();

          List<List<DoctorQueueTicketEntity>> columnsData = List.generate(columnCount, (_) => []);
          for (int i = 0; i < tickets.length; i++) {
            columnsData[i ~/ itemsPerColumn].add(tickets[i]);
          }
          
          return Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(columnCount, (colIndex) {
                final bool isLastColumn = colIndex == columnCount - 1;
                return Padding(
                  padding: EdgeInsets.only(
                    left: colIndex == 0 ? 0 : _kSpacing / 2,
                    right: isLastColumn ? 0 : _kSpacing / 2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(columnsData[colIndex].length, (itemIndex) {
                      return _buildTicketItem(
                        ticket: columnsData[colIndex][itemIndex],
                        isWaiting: isWaiting,
                        size: layout.ticketSize,
                      );
                    }),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  /// Виджет одного талона, который вместе со своим отступом формирует "ячейку".
  Widget _buildTicketItem({
    required DoctorQueueTicketEntity ticket,
    required bool isWaiting,
    required Size size,
  }) {
    final Color backgroundColor =
        isWaiting ? Colors.white : const Color(0xFF4CAF50);
    final Color textColor =
        isWaiting ? const Color(0xFF333333) : Colors.white;
    final double fontSize = size.height * 0.4;
    
    return SizedBox(
      width: size.width,
      height: size.height + _kSpacing, 
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              ticket.ticketNumber,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // --- Остальные виджеты остаются без изменений ---

  Widget _buildNewHeader({
    required String cabinetNumber,
    required String doctorName,
    required String specialty,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667EEA),
            const Color(0xFF764BA2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -8,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              // Эффект матового стекла
              backgroundBlendMode: BlendMode.overlay,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                // Дополнительный эффект свечения
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: -2,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Кабинет',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cabinetNumber,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                        Shadow(
                          color: Colors.white.withOpacity(0.3),
                          offset: const Offset(0, 0),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                // Эффект матового стекла для текста врача
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    specialty,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueStatusHeader() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF667EEA),
                    const Color(0xFF5B6BC0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 0),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'В очереди',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFD54F),
                    const Color(0xFFFFC107),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC107).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 0),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Идёт приём',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      color: const Color(0xFFFEE2E2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 80),
            const SizedBox(height: 20),
            const Text('Ошибка загрузки данных', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Color(0xFFB91C1C))),
            const SizedBox(height: 20),
            const Text('Попытка переподключения через 5 секунд...', style: TextStyle(fontSize: 16, color: Color(0xFF991B1B))),
          ],
        ),
      ),
    );
  }
}