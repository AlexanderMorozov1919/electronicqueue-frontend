import 'dart:convert';
import 'dart:typed_data';
import 'package:elqueue/administrator/domain/repositories/ad_repository.dart';
import 'package:elqueue/administrator/domain/usecases/manage_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:elqueue/administrator/domain/entities/ad_entity.dart';
import 'package:elqueue/administrator/presentation/blocs/ad/ad_bloc.dart';
import 'package:elqueue/administrator/presentation/widgets/ad/ad_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'dart:html' as html;

class AdCardWidget extends StatefulWidget {
  final AdEntity ad;
  const AdCardWidget({super.key, required this.ad});

  @override
  State<AdCardWidget> createState() => _AdCardWidgetState();
}

class _AdCardWidgetState extends State<AdCardWidget> {
  AdEntity? _fullAd;
  bool _isLoading = false;
  VideoPlayerController? _videoController;
  String? _videoObjectUrl;

  @override
  void initState() {
    super.initState();
    _fullAd = widget.ad;
    // Если тип медиа определен, но самих данных нет - дозагружаем
    if ((widget.ad.mediaType == 'image' && (widget.ad.picture == null || widget.ad.picture!.isEmpty)) ||
        (widget.ad.mediaType == 'video' && (widget.ad.video == null || widget.ad.video!.isEmpty))) {
      _fetchAdMedia();
    } else if (widget.ad.mediaType == 'video' && widget.ad.video != null) {
      _initializeVideoPlayer(_safeBase64Decode(widget.ad.video!));
    }
  }

  // Улучшенная функция декодирования
  Uint8List _safeBase64Decode(String source) {
    try {
      return base64Decode(source);
    } catch (e) {
      print("Error decoding base64 string: $e");
      return Uint8List(0); // Возвращаем пустой список байт в случае ошибки
    }
  }

  Future<void> _initializeVideoPlayer(Uint8List videoBytes) async {
    if (kIsWeb && videoBytes.isNotEmpty) {
      _disposeVideoPlayer(); // Очищаем предыдущий контроллер
      final blob = html.Blob([videoBytes], 'video/mp4');
      _videoObjectUrl = html.Url.createObjectUrlFromBlob(blob);
      _videoController = VideoPlayerController.networkUrl(Uri.parse(_videoObjectUrl!))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController?.setLooping(true);
            _videoController?.setVolume(0);
            _videoController?.play();
          }
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

  Future<void> _fetchAdMedia() async {
    if (widget.ad.id == null) return;
    setState(() => _isLoading = true);
    try {
      // Получаем репозиторий из контекста
      final adRepository = context.read<AdRepository>();
      final getAdById = GetAdById(adRepository);
      final dartz.Either<dynamic, AdEntity> result = await getAdById(widget.ad.id!);

      if (mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка загрузки медиа: ${failure.message}')),
            );
            setState(() => _isLoading = false);
          },
          (fetchedAd) {
            setState(() {
              _fullAd = fetchedAd;
              if (fetchedAd.mediaType == 'video' && fetchedAd.video != null) {
                _initializeVideoPlayer(_safeBase64Decode(fetchedAd.video!));
              }
              _isLoading = false;
            });
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось загрузить медиа: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _disposeVideoPlayer();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Подтверждение'),
        content: const Text('Вы уверены, что хотите удалить этот рекламный материал?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (widget.ad.id != null) {
                context.read<AdBloc>().add(DeleteAdById(widget.ad.id!));
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AdBloc>(),
        child: AdEditDialog(ad: _fullAd),
      ),
    ).then((_) {
       context.read<AdBloc>().add(LoadAds());
    });
  }

  void _showPreview(BuildContext context) {
    if (_fullAd == null) return;
    final adData = _fullAd!;

    Widget content;
    if (adData.mediaType == 'image' && adData.picture != null && adData.picture!.isNotEmpty) {
      content = Image.memory(_safeBase64Decode(adData.picture!));
    } else if (adData.mediaType == 'video' && adData.video != null && adData.video!.isNotEmpty) {
      content = _VideoPreviewDialog(videoBytes: _safeBase64Decode(adData.video!));
    } else {
      return;
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adData = _fullAd ?? widget.ad;

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Positioned.fill(
            child: InkWell(
              onTap: () => _showPreview(context),
              child: _buildMediaContent(adData),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Column(
              children: [
                IconButton(
                  onPressed: () => _showEditDialog(context),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  tooltip: 'Редактировать',
                  style: IconButton.styleFrom(backgroundColor: Colors.black45),
                ),
                const SizedBox(height: 4),
                IconButton(
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  tooltip: 'Удалить',
                  style: IconButton.styleFrom(backgroundColor: Colors.black45),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  avatar: Icon(
                      adData.mediaType == 'video' ? Icons.repeat : Icons.timer_outlined,
                      color: Colors.white),
                  label: Text(
                      adData.mediaType == 'video' ? '${adData.repeatCount} раз' : '${adData.durationSec} сек',
                      style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.black54,
                ),
                Switch(
                  value: adData.isEnabled,
                  onChanged: (newValue) {
                    context.read<AdBloc>().add(UpdateAdInfo(adData.copyWith(isEnabled: newValue)));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(AdEntity adData) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (adData.mediaType == 'image' && adData.picture != null && adData.picture!.isNotEmpty) {
      final imageBytes = _safeBase64Decode(adData.picture!);
      if (imageBytes.isEmpty) {
        return const Icon(Icons.broken_image, color: Colors.red, size: 60);
      }
      return Image.memory(imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red, size: 60));
    }
    if (adData.mediaType == 'video' && _videoController != null && _videoController!.value.isInitialized) {
      // ИСПРАВЛЕНИЕ: Оборачиваем плеер в IgnorePointer
      return IgnorePointer(
        child: SizedBox.expand(
            child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!)))),
      );
    }
    return Center(child: Icon(adData.mediaType == 'video' ? Icons.videocam : Icons.image_not_supported, color: Colors.grey, size: 60));
  }
}

class _VideoPreviewDialog extends StatefulWidget {
  final Uint8List videoBytes;
  const _VideoPreviewDialog({required this.videoBytes});

  @override
  State<_VideoPreviewDialog> createState() => _VideoPreviewDialogState();
}

class _VideoPreviewDialogState extends State<_VideoPreviewDialog> {
  VideoPlayerController? _controller;
  String? _videoObjectUrl;

  @override
  void initState() {
    super.initState();
    if (kIsWeb && widget.videoBytes.isNotEmpty) {
      final blob = html.Blob([widget.videoBytes], 'video/mp4');
      _videoObjectUrl = html.Url.createObjectUrlFromBlob(blob);
      _controller = VideoPlayerController.networkUrl(Uri.parse(_videoObjectUrl!))
        ..initialize().then((_) {
          if(mounted) setState(() {});
          _controller?.play();
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    if (_videoObjectUrl != null) {
      html.Url.revokeObjectUrl(_videoObjectUrl!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null && _controller!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_controller!),
            VideoProgressIndicator(_controller!, allowScrubbing: true),
            _buildControls(),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
  
  Widget _buildControls() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
        });
      },
      child: Container(
        color: Colors.transparent, 
        child: Center(
          child: AnimatedOpacity(
            opacity: _controller!.value.isPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.play_arrow, size: 60, color: Colors.white),
          ),
        ),
      ),
    );
  }
}