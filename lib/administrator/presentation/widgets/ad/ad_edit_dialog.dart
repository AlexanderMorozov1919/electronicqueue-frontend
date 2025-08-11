import 'dart:convert';
import 'dart:typed_data';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:elqueue/administrator/domain/entities/ad_entity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elqueue/administrator/presentation/blocs/ad/ad_bloc.dart';

enum MediaType { image, video }

class AdEditDialog extends StatefulWidget {
  final AdEntity? ad;
  const AdEditDialog({super.key, this.ad});

  @override
  State<AdEditDialog> createState() => _AdEditDialogState();
}

class _AdEditDialogState extends State<AdEditDialog> {
  late final TextEditingController _durationController;
  late final TextEditingController _repeatCountController;

  MediaType _mediaType = MediaType.image;
  Uint8List? _mediaBytes;
  String? _fileName;

  bool _isEnabled = true;
  bool _receptionOn = true;
  bool _scheduleOn = true;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    if (widget.ad != null) {
      if (widget.ad!.mediaType == 'video') {
        _mediaType = MediaType.video;
        if (widget.ad!.video != null && widget.ad!.video!.isNotEmpty) {
          _mediaBytes = base64Decode(widget.ad!.video!);
        }
      } else {
        _mediaType = MediaType.image;
        if (widget.ad!.picture != null && widget.ad!.picture!.isNotEmpty) {
          _mediaBytes = base64Decode(widget.ad!.picture!);
        }
      }
      _durationController =
          TextEditingController(text: widget.ad!.durationSec.toString());
      _repeatCountController =
          TextEditingController(text: widget.ad!.repeatCount.toString());
      _isEnabled = widget.ad!.isEnabled;
      _receptionOn = widget.ad!.receptionOn;
      _scheduleOn = widget.ad!.scheduleOn;
    } else {
      _durationController = TextEditingController(text: '5');
      _repeatCountController = TextEditingController(text: '1');
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _repeatCountController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: _mediaType == MediaType.image ? FileType.image : FileType.custom,
      allowedExtensions: _mediaType == MediaType.image
          ? ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp']
          : ['mp4'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _mediaBytes = result.files.single.bytes;
        _fileName = result.files.single.name;
      });
    }
  }

  void _handleSubmit() {
    if (_mediaBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Пожалуйста, выберите файл (изображение или видео)')));
      return;
    }

    final duration = int.tryParse(_durationController.text);
    final repeatCount = int.tryParse(_repeatCountController.text);

    if (_mediaType == MediaType.image && (duration == null || duration <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Длительность для изображения должна быть положительным числом')));
      return;
    }

    if (_mediaType == MediaType.video &&
        (repeatCount == null || repeatCount <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Количество повторов для видео должно быть положительным числом')));
      return;
    }

    final adEntity = AdEntity(
      id: widget.ad?.id,
      mediaType: _mediaType == MediaType.image ? 'image' : 'video',
      picture:
          _mediaType == MediaType.image ? base64Encode(_mediaBytes!) : null,
      video: _mediaType == MediaType.video ? base64Encode(_mediaBytes!) : null,
      durationSec: duration ?? 5, // Default for video
      repeatCount: repeatCount ?? 1, // Default for image
      isEnabled: _isEnabled,
      receptionOn: _receptionOn,
      scheduleOn: _scheduleOn,
    );

    if (widget.ad == null) {
      context.read<AdBloc>().add(AddAd(adEntity));
    } else {
      context.read<AdBloc>().add(UpdateAdInfo(adEntity));
    }
    Navigator.of(context).pop();
  }

  Widget _buildMediaPreview() {
    if (_mediaBytes == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text('Перетащите файл или нажмите для выбора',
                textAlign: TextAlign.center),
            SizedBox(height: 4),
            Text(
              'Изображения (PNG, JPG...) или видео (MP4)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    if (_mediaType == MediaType.image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(_mediaBytes!, fit: BoxFit.contain),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_outlined, size: 50, color: Colors.grey),
            const SizedBox(height: 8),
            Text(_fileName ?? 'Видео файл выбран',
                style: const TextStyle(color: Colors.black)),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.ad == null ? 'Добавить рекламу' : 'Редактировать рекламу'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ToggleButtons(
                isSelected: [
                  _mediaType == MediaType.image,
                  _mediaType == MediaType.video
                ],
                onPressed: (index) {
                  setState(() {
                    _mediaType = index == 0 ? MediaType.image : MediaType.video;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(children: [Icon(Icons.image), SizedBox(width: 8), Text('Изображение')]),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(children: [Icon(Icons.videocam), SizedBox(width: 8), Text('Видео')]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropTarget(
                onDragDone: (detail) async {
                  if (detail.files.isNotEmpty) {
                    final file = detail.files.first;
                    final bytes = await file.readAsBytes();
                    setState(() {
                      _mediaBytes = bytes;
                      _fileName = file.name;
                    });
                  }
                },
                onDragEntered: (detail) => setState(() => _isDragging = true),
                onDragExited: (detail) => setState(() => _isDragging = false),
                child: InkWell(
                  onTap: _pickMedia,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _isDragging
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.grey[200],
                      border: Border.all(
                        color: _isDragging ? Colors.blue : Colors.grey,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildMediaPreview(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_mediaType == MediaType.image)
                TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Длительность показа (секунды)',
                    border: OutlineInputBorder(),
                  ),
                )
              else
                TextField(
                  controller: _repeatCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Количество повторов',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Включено'),
                value: _isEnabled,
                onChanged: (value) {
                  setState(() => _isEnabled = value);
                },
              ),
              SwitchListTile(
                title: const Text('На табло регистратуры'),
                value: _receptionOn,
                onChanged: (value) {
                  setState(() => _receptionOn = value);
                },
              ),
              SwitchListTile(
                title: const Text('На общем расписании'),
                value: _scheduleOn,
                onChanged: (value) {
                  setState(() => _scheduleOn = value);
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