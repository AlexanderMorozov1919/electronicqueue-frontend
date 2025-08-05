import 'dart:convert';
import 'dart:typed_data';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:elqueue/administrator/domain/entities/ad_entity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elqueue/administrator/presentation/blocs/ad/ad_bloc.dart';

class AdEditDialog extends StatefulWidget {
  final AdEntity? ad;
  const AdEditDialog({super.key, this.ad});

  @override
  State<AdEditDialog> createState() => _AdEditDialogState();
}

class _AdEditDialogState extends State<AdEditDialog> {
  late final TextEditingController _durationController;
  Uint8List? _imageBytes;
  bool _isEnabled = true;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    if (widget.ad != null) {
      _durationController = TextEditingController(text: widget.ad!.durationSec.toString());
      // --- ИСПРАВЛЕНИЕ ЗДЕСЬ ---
      // Проверяем, что картинка не null, перед декодированием
      if (widget.ad!.picture != null && widget.ad!.picture!.isNotEmpty) {
        _imageBytes = base64Decode(widget.ad!.picture!);
      }
      _isEnabled = widget.ad!.isEnabled;
    } else {
      _durationController = TextEditingController(text: '5');
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
      });
    }
  }

  void _handleSubmit() {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пожалуйста, выберите изображение')));
      return;
    }
    final duration = int.tryParse(_durationController.text);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Длительность должна быть положительным числом')));
      return;
    }

    final adEntity = AdEntity(
      id: widget.ad?.id,
      picture: base64Encode(_imageBytes!),
      durationSec: duration,
      isEnabled: _isEnabled,
    );

    if (widget.ad == null) {
      context.read<AdBloc>().add(AddAd(adEntity));
    } else {
      context.read<AdBloc>().add(UpdateAdInfo(adEntity));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.ad == null ? 'Добавить рекламу' : 'Редактировать рекламу'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag and Drop Area
              DropTarget(
                onDragDone: (detail) async {
                  if (detail.files.isNotEmpty) {
                    final file = detail.files.first;
                    final bytes = await file.readAsBytes();
                    setState(() {
                      _imageBytes = bytes;
                    });
                  }
                },
                onDragEntered: (detail) => setState(() => _isDragging = true),
                onDragExited: (detail) => setState(() => _isDragging = false),
                child: InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _isDragging ? Colors.blue.withOpacity(0.1) : Colors.grey[200],
                      border: Border.all(
                        color: _isDragging ? Colors.blue : Colors.grey,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload_outlined, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Перетащите файл или нажмите для выбора', textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Duration field
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Длительность показа (секунды)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // IsEnabled switch
              SwitchListTile(
                title: const Text('Включено'),
                value: _isEnabled,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}