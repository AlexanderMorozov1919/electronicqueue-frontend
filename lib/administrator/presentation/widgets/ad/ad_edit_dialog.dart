import 'dart:convert';
import 'dart:typed_data';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:elqueue/administrator/domain/entities/ad_entity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elqueue/administrator/presentation/blocs/ad/ad_bloc.dart';
import 'package:video_player/video_player.dart';
import 'dart:html' as html;

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

  // Исходные данные, с которыми открылся диалог
  MediaType _initialMediaType = MediaType.image;
  Uint8List? _initialImageBytes;
  Uint8List? _initialVideoBytes;

  // Новые, выбранные пользователем данные
  MediaType _selectedMediaType = MediaType.image;
  Uint8List? _newMediaBytes;
  String? _newFileName;

  bool _isEnabled = true;
  bool _receptionOn = true;
  bool _scheduleOn = true;
  bool _isDragging = false;

  VideoPlayerController? _videoController;
  String? _videoObjectUrl;

  @override
  void initState() {
    super.initState();
    if (widget.ad != null) {
      if (widget.ad!.mediaType == 'video') {
        _initialMediaType = MediaType.video;
        if (widget.ad!.video != null && widget.ad!.video!.isNotEmpty) {
          _initialVideoBytes = _safeBase64Decode(widget.ad!.video!);
          _initializeVideoPlayer(_initialVideoBytes!);
        }
      } else {
        _initialMediaType = MediaType.image;
        if (widget.ad!.picture != null && widget.ad!.picture!.isNotEmpty) {
          _initialImageBytes = _safeBase64Decode(widget.ad!.picture!);
        }
      }
      _selectedMediaType = _initialMediaType;
      _durationController = TextEditingController(text: widget.ad!.durationSec.toString());
      _repeatCountController = TextEditingController(text: widget.ad!.repeatCount.toString());
      _isEnabled = widget.ad!.isEnabled;
      _receptionOn = widget.ad!.receptionOn;
      _scheduleOn = widget.ad!.scheduleOn;
    } else {
      _durationController = TextEditingController(text: '5');
      _repeatCountController = TextEditingController(text: '1');
    }
  }

  Uint8List _safeBase64Decode(String source) {
    try {
      return base64Decode(source);
    } catch (e) {
      print("Error decoding base64 string: $e");
      return Uint8List(0);
    }
  }

  void _initializeVideoPlayer(Uint8List videoBytes) {
    if (kIsWeb && videoBytes.isNotEmpty) {
      _disposeVideoPlayer();
      final blob = html.Blob([videoBytes], 'video/mp4');
      _videoObjectUrl = html.Url.createObjectUrlFromBlob(blob);
      _videoController = VideoPlayerController.networkUrl(Uri.parse(_videoObjectUrl!))
        ..initialize().then((_) {
          if (mounted) setState(() {});
          _videoController?.setVolume(0);
          _videoController?.play();
          _videoController?.setLooping(true);
        });
    }
  }

  void _disposeVideoPlayer() {
    _videoController?.dispose();
    _videoController = null;
    if (_videoObjectUrl != null) {
      html.Url.revokeObjectUrl(_videoObjectUrl!);
      _videoObjectUrl = null;
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _repeatCountController.dispose();
    _disposeVideoPlayer();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, // Используем кастомный тип, чтобы выбрать любой файл
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'mp4'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      // Автоматически определяем тип медиа по расширению
      final file = result.files.single;
      final ext = file.extension?.toLowerCase();
      final newType = (ext == 'mp4') ? MediaType.video : MediaType.image;
      
      setState(() {
        _selectedMediaType = newType;
      });
      _handleMediaSelected(file.bytes!, file.name);
    }
  }

  void _handleMediaSelected(Uint8List bytes, String name) {
    setState(() {
      _newMediaBytes = bytes;
      _newFileName = name;
      if (_selectedMediaType == MediaType.video) {
        _initializeVideoPlayer(bytes);
      } else {
        _disposeVideoPlayer();
      }
    });
  }

  void _handleSubmit() {
    Uint8List? finalMediaBytes = _newMediaBytes ?? (_selectedMediaType == _initialMediaType ? (_initialMediaType == MediaType.image ? _initialImageBytes : _initialVideoBytes) : null);

    if (finalMediaBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пожалуйста, выберите файл (изображение или видео)')));
      return;
    }

    final duration = int.tryParse(_durationController.text);
    final repeatCount = int.tryParse(_repeatCountController.text);

    if (_selectedMediaType == MediaType.image && (duration == null || duration <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Длительность для изображения должна быть положительным числом')));
      return;
    }

    if (_selectedMediaType == MediaType.video && (repeatCount == null || repeatCount <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Количество повторов для видео должно быть положительным числом')));
      return;
    }

    final adEntity = AdEntity(
      id: widget.ad?.id,
      mediaType: _selectedMediaType == MediaType.image ? 'image' : 'video',
      picture: _selectedMediaType == MediaType.image ? base64Encode(finalMediaBytes) : null,
      video: _selectedMediaType == MediaType.video ? base64Encode(finalMediaBytes) : null,
      durationSec: duration ?? 5,
      repeatCount: repeatCount ?? 1,
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

  Widget _buildMediaPlaceholder() {
    final bool isImageType = _selectedMediaType == MediaType.image;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload_outlined, size: 50, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            isImageType ? 'Перетащите изображение или нажмите для выбора' : 'Перетащите видео или нажмите для выбора',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            isImageType 
              ? 'Поддерживаемые форматы изображений: PNG, JPG, GIF, WEBP, BMP'
              : 'Поддерживаемый формат видео: MP4',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview() {
    Uint8List? currentBytes = _newMediaBytes;
    MediaType currentType = _selectedMediaType;

    // Если новый файл не выбран, пытаемся показать исходный, если тип совпадает
    if (currentBytes == null && _selectedMediaType == _initialMediaType) {
      currentBytes = _initialMediaType == MediaType.image ? _initialImageBytes : _initialVideoBytes;
    }

    if (currentBytes == null) {
      return _buildMediaPlaceholder();
    }

    if (currentType == MediaType.image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(currentBytes, fit: BoxFit.contain),
      );
    }

    if (currentType == MediaType.video && _videoController != null && _videoController!.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      );
    }
    
    return const Center(child: CircularProgressIndicator());
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
              ToggleButtons(
                isSelected: [_selectedMediaType == MediaType.image, _selectedMediaType == MediaType.video],
                onPressed: (index) {
                  final newType = index == 0 ? MediaType.image : MediaType.video;
                  if (_selectedMediaType != newType) {
                    setState(() {
                      _selectedMediaType = newType;
                      _newMediaBytes = null; // Сбрасываем выбранный файл при смене типа
                      _newFileName = null;
                      
                      // Если новый тип совпадает с исходным, восстанавливаем видеоплеер
                      if (newType == _initialMediaType && newType == MediaType.video && _initialVideoBytes != null) {
                          _initializeVideoPlayer(_initialVideoBytes!);
                      } else {
                         _disposeVideoPlayer();
                      }
                    });
                  }
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
                    final ext = file.name.split('.').last.toLowerCase();
                    final bytes = await file.readAsBytes();
                    setState(() {
                       // Автоматически переключаем тип на основе расширения
                       _selectedMediaType = (ext == 'mp4') ? MediaType.video : MediaType.image;
                    });
                    _handleMediaSelected(bytes, file.name);
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
                      color: _isDragging ? Colors.blue.withOpacity(0.1) : Colors.grey[200],
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
              if (_selectedMediaType == MediaType.image)
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