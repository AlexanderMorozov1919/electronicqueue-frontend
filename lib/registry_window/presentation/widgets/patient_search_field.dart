import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/patient_entity.dart';
import '../blocs/appointment/appointment_bloc.dart';
import 'create_patient_dialog.dart';

class PatientSearchField extends StatefulWidget {
  final TextEditingController controller;
  final Function(PatientEntity) onPatientSelected;
  final VoidCallback onPatientCleared;

  const PatientSearchField({
    super.key,
    required this.controller,
    required this.onPatientSelected,
    required this.onPatientCleared,
  });

  @override
  State<PatientSearchField> createState() => _PatientSearchFieldState();
}

class _PatientSearchFieldState extends State<PatientSearchField> {
  Timer? _debounce;
  List<PatientEntity> _suggestions = [];
  bool _isLoading = false;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      // Небольшая задержка перед скрытием, чтобы успел сработать onTap
      Future.delayed(const Duration(milliseconds: 200), () {
        _removeOverlay();
      });
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState(() { _isLoading = true; });
    // Обновляем UI оверлея, чтобы показать индикатор загрузки
    _overlayEntry?.markNeedsBuild();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      
      if (query.length < 2) {
        setState(() {
          _isLoading = false;
          _suggestions = [];
          _overlayEntry?.markNeedsBuild();
        });
        return;
      }

      final bloc = context.read<AppointmentBloc>();
      final result = await bloc.patientRepository.searchPatients(query);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _suggestions = result.getOrElse(() => []);
          _overlayEntry?.markNeedsBuild();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          labelText: 'Пациент (ФИО, ОМС, паспорт)',
          border: const OutlineInputBorder(),
          hintText: 'Начните вводить для поиска...',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              widget.controller.clear();
              widget.onPatientCleared();
              setState(() { _suggestions = []; });
              _onSearchChanged(''); // Обновляем состояние поиска
            },
          ),
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            child: _buildSuggestionsContainer(),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsContainer() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_suggestions.isEmpty && widget.controller.text.length > 1) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text('Пациент не найден'),
            const SizedBox(height: 8),
            ElevatedButton(
              child: const Text('Создать нового пациента'),
              onPressed: () async {
                _focusNode.unfocus();
                final patientData = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (_) => const CreatePatientDialog(),
                );
                if (patientData != null && mounted) {
                  context.read<AppointmentBloc>().add(CreatePatient(patientData));
                }
              },
            ),
          ],
        ),
      );
    }

    if (_suggestions.isNotEmpty) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 250), 
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            final patient = _suggestions[index];
            return ListTile(
              title: Text(patient.fullName),
              subtitle: Text('ОМС: ${patient.omsNumber ?? 'не указан'}'),
              onTap: () {
                // 1. Обновляем текст в поле ввода НАПРЯМУЮ.
                widget.controller.text = patient.fullName;
                
                // 2. Вызываем колбэк, чтобы уведомить BLoC о выборе.
                widget.onPatientSelected(patient);
                
                // 3. Убираем фокус и прячем подсказки.
                _focusNode.unfocus();
              },
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}