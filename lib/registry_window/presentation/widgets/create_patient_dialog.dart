import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; // НОВЫЙ ИМПОРТ

class CreatePatientDialog extends StatefulWidget {
  const CreatePatientDialog({super.key});

  @override
  State<CreatePatientDialog> createState() => _CreatePatientDialogState();
}

class _CreatePatientDialogState extends State<CreatePatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _passportSeriesController = TextEditingController();
  final _passportNumberController = TextEditingController();
  final _omsController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _birthDate;

  // Создаем маски для полей ввода
  final _omsMask = MaskTextInputFormatter(mask: '#### #### #### ####', filter: {"#": RegExp(r'[0-9]')});
  final _phoneMask = MaskTextInputFormatter(mask: '+7(###)###-##-##', filter: {"#": RegExp(r'[0-9]')});
  final _passportSeriesMask = MaskTextInputFormatter(mask: '## ##', filter: {"#": RegExp(r'[0-9]')});
  final _passportNumberMask = MaskTextInputFormatter(mask: '######', filter: {"#": RegExp(r'[0-9]')});

  @override
  void dispose() {
    _fullNameController.dispose();
    _passportSeriesController.dispose();
    _passportNumberController.dispose();
    _omsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новый пациент'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'ФИО'),
                  validator: (value) => (value?.isEmpty ?? true) ? 'Обязательное поле' : null,
                ),
                TextFormField(
                  controller: _omsController,
                  decoration: const InputDecoration(labelText: 'Номер полиса ОМС'),
                  validator: (value) => (value?.isEmpty ?? true) ? 'Обязательное поле' : null,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_omsMask],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _passportSeriesController,
                        decoration: const InputDecoration(labelText: 'Серия паспорта'),
                        validator: (value) => (value?.isEmpty ?? true) ? 'Обязательное поле' : null,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_passportSeriesMask],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _passportNumberController,
                        decoration: const InputDecoration(labelText: 'Номер паспорта'),
                        validator: (value) => (value?.isEmpty ?? true) ? 'Обязательное поле' : null,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_passportNumberMask],
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Телефон'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneMask],
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _birthDate ?? DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() { _birthDate = pickedDate; });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Дата рождения', border: OutlineInputBorder()),
                    child: Text(_birthDate != null ? DateFormat('dd.MM.yyyy').format(_birthDate!) : 'Выберите дату'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _birthDate != null) {
              final patientData = {
                'full_name': _fullNameController.text,
                'oms_number': _omsMask.getUnmaskedText(),
                'passport_series': _passportSeriesMask.getUnmaskedText(),
                'passport_number': _passportNumberMask.getUnmaskedText(),
                'phone': _phoneMask.getUnmaskedText(),
                'birth_date': _birthDate!.toUtc().toIso8601String(),
              };
              Navigator.of(context).pop(patientData);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Заполните все обязательные поля'), backgroundColor: Colors.orange,)
              );
            }
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}