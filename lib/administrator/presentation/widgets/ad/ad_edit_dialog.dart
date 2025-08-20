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

  // Списки поддерживаемых расширений
  static const _supportedImageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'};
  static const _supportedVideoExtensions = {'mp4'};

  @override
  void initState() {
    super.initState();
    print('[AdEditDialog] initState. Editing ad: ${widget.ad != null ? widget.ad!.id : 'new'}');
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
    } catch (e, s) {
      print("[AdEditDialog] Error decoding base64 string: $e\n$s");
      return Uint8List(0);
    }
  }

  void _initializeVideoPlayer(Uint8List videoBytes) {
    print('[AdEditDialog] _initializeVideoPlayer started. Bytes length: ${videoBytes.length}');
    if (kIsWeb && videoBytes.isNotEmpty) {
      try {
        _disposeVideoPlayer();
        final blob = html.Blob([videoBytes], 'video/mp4');
        _videoObjectUrl = html.Url.createObjectUrlFromBlob(blob);
        print('[AdEditDialog] Created video object URL: $_videoObjectUrl');
        _videoController = VideoPlayerController.networkUrl(Uri.parse(_videoObjectUrl!))
          ..initialize().then((_) {
            print('[AdEditDialog] Video player initialized.');
            if (mounted) setState(() {});
            _videoController?.setVolume(0);
            _videoController?.play();
            _videoController?.setLooping(true);
            print('[AdEditDialog] Video playing.');
          }).catchError((error, stackTrace) {
            print('[AdEditDialog] ERROR during video player .initialize(): $error\n$stackTrace');
          });
      } catch (e, s) {
        print('[AdEditDialog] EXCEPTION in _initializeVideoPlayer: $e\n$s');
      }
    } else {
      print('[AdEditDialog] _initializeVideoPlayer skipped. isWeb: $kIsWeb, videoBytes empty: ${videoBytes.isEmpty}');
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
    print('[AdEditDialog] dispose.');
    _durationController.dispose();
    _repeatCountController.dispose();
    _disposeVideoPlayer();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    print('[AdEditDialog] _pickMedia started.');
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [..._supportedImageExtensions, ..._supportedVideoExtensions],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;
        print('[AdEditDialog] File picked: ${file.name}, size: ${file.size}, ext: ${file.extension}');
        final ext = file.extension?.toLowerCase();

        if (ext == null || !(_supportedImageExtensions.contains(ext) || _supportedVideoExtensions.contains(ext))) {
          print('[AdEditDialog] Invalid file type picked: $ext. Showing dialog.');
          _showInvalidFileTypeDialog();
          return;
        }

        final newType = _supportedVideoExtensions.contains(ext) ? MediaType.video : MediaType.image;

        setState(() {
          _selectedMediaType = newType;
          print('[AdEditDialog] Media type set to: $newType');
        });
        _handleMediaSelected(file.bytes!, file.name);
      } else {
        print('[AdEditDialog] File picker returned null or file has no bytes.');
      }
    } catch (e, s) {
      print('[AdEditDialog] EXCEPTION in _pickMedia: $e\n$s');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе файла: $e')),
      );
    }
  }

  void _handleMediaSelected(Uint8List bytes, String name) {
    print('[AdEditDialog] _handleMediaSelected called with file: $name, bytes length: ${bytes.length}, type: $_selectedMediaType');
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

  // ИСПРАВЛЕНИЕ: Замена SnackBar на AlertDialog
  void _showInvalidFileTypeDialog() {
    print('[AdEditDialog] _showInvalidFileTypeDialog called.');
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Неверный формат файла'),
          content: const Text('Не поддерживается тип файла, который вы загрузили.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleSubmit() {
    print('[AdEditDialog] _handleSubmit started.');
    Uint8List? finalMediaBytes = _newMediaBytes ?? (_selectedMediaType == _initialMediaType ? (_initialMediaType == MediaType.image ? _initialImageBytes : _initialVideoBytes) : null);

    if (finalMediaBytes == null) {
      print('[AdEditDialog] _handleSubmit aborted: finalMediaBytes is null.');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пожалуйста, выберите файл (изображение или видео)')));
      return;
    }
    print('[AdEditDialog] _handleSubmit: final media bytes length: ${finalMediaBytes.length}');

    final duration = int.tryParse(_durationController.text);
    final repeatCount = int.tryParse(_repeatCountController.text);

    if (_selectedMediaType == MediaType.image && (duration == null || duration <= 0)) {
      print('[AdEditDialog] _handleSubmit aborted: invalid duration for image.');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Длительность для изображения должна быть положительным числом')));
      return;
    }

    if (_selectedMediaType == MediaType.video && (repeatCount == null || repeatCount <= 0)) {
      print('[AdEditDialog] _handleSubmit aborted: invalid repeat count for video.');
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
    print('[AdEditDialog] Submitting AdEntity: id=${adEntity.id}, mediaType=${adEntity.mediaType}, isEnabled=${adEntity.isEnabled}');

    if (widget.ad == null) {
      print('[AdEditDialog] Dispatching AddAd event.');
      context.read<AdBloc>().add(AddAd(adEntity));
    } else {
      print('[AdEditDialog] Dispatching UpdateAdInfo event.');
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
              ? 'Поддерживаемые типы: PNG, JPG, GIF, WEBP, BMP'
              : 'Поддерживаемый тип: MP4',
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
      return IgnorePointer(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
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
                      _newMediaBytes = null;
                      _newFileName = null;
                      
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
                  print('[AdEditDialog] onDragDone triggered. File count: ${detail.files.length}');
                  try {
                    if (detail.files.isNotEmpty) {
                      final file = detail.files.first;
                      final ext = file.name.split('.').last.toLowerCase();
                      print('[AdEditDialog] File dropped: ${file.name}, size: ${await file.length()}, ext: $ext');

                      if (!(_supportedImageExtensions.contains(ext) || _supportedVideoExtensions.contains(ext))) {
                        print('[AdEditDialog] Invalid file type dropped: $ext. Showing dialog.');
                        _showInvalidFileTypeDialog();
                        return;
                      }

                      final bytes = await file.readAsBytes();
                      print('[AdEditDialog] File bytes read. Length: ${bytes.length}');
                      setState(() {
                        _selectedMediaType = _supportedVideoExtensions.contains(ext) ? MediaType.video : MediaType.image;
                        print('[AdEditDialog] Media type set to: $_selectedMediaType');
                      });
                      _handleMediaSelected(bytes, file.name);
                    }
                  } catch (e, s) {
                    print('[AdEditDialog] EXCEPTION in onDragDone: $e\n$s');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка при обработке файла: $e')),
                    );
                  }
                },
                onDragEntered: (detail) {
                  print('[AdEditDialog] onDragEntered');
                  setState(() => _isDragging = true);
                },
                onDragExited: (detail) {
                  print('[AdEditDialog] onDragExited');
                  setState(() => _isDragging = false);
                },
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