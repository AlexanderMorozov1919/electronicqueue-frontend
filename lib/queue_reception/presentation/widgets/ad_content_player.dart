import 'dart:async';
import 'package:elqueue/queue_reception/domain/entities/ad_display.dart';
import 'package:elqueue/queue_reception/presentation/blocs/ad_display_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
// Импорты для веб-специфичной функциональности
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

class AdContentPlayer extends StatefulWidget {
  final AdDisplay ad;
  const AdContentPlayer({super.key, required this.ad});

  @override
  State<AdContentPlayer> createState() => _AdContentPlayerState();
}

class _AdContentPlayerState extends State<AdContentPlayer> {
  Timer? _imageTimer;
  VideoPlayerController? _videoController;
  int _loopCount = 0;
  String? _videoObjectUrl; // Для хранения Blob URL и его последующей очистки

  @override
  void initState() {
    super.initState();
    _initializeContent();
  }

  @override
  void didUpdateWidget(covariant AdContentPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Пересоздаем плеер только если ID рекламы изменился
    if (oldWidget.ad.id != widget.ad.id) {
      _disposeControllers();
      _initializeContent();
    }
  }

  void _initializeContent() {
    if (widget.ad.mediaType == 'image' && widget.ad.imageBytes != null) {
      // Для изображений используем таймер
      _imageTimer =
          Timer(Duration(seconds: widget.ad.durationSec), _onContentFinished);
    } else if (widget.ad.mediaType == 'video' && widget.ad.videoBytes != null) {
      // Для видео используем Blob URL (только для веба)
      if (kIsWeb) {
        // Создаем Blob из байтов видео
        final blob = html.Blob([widget.ad.videoBytes!], 'video/mp4');
        // Создаем временный URL для этого Blob
        _videoObjectUrl = html.Url.createObjectUrlFromBlob(blob);

        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(_videoObjectUrl!))
              ..initialize().then((_) {
                if (!mounted) return;
                setState(() {});
                _videoController?.setVolume(0); // Отключаем звук (требование браузеров для autoplay)
                _videoController?.play();
                _videoController?.addListener(_videoListener);
              });
      } else {
        // Заглушка для не-веб платформ
        print(
            "Video playback from memory is only supported on the web platform in this implementation.");
      }
    }
  }

  void _videoListener() {
    if (!mounted ||
        _videoController == null ||
        !_videoController!.value.isInitialized) return;

    final position = _videoController!.value.position;
    final duration = _videoController!.value.duration;

    // Проверяем, что видео доиграло до конца
    if (position > Duration.zero && position >= duration) {
      _videoController!.removeListener(_videoListener); // Избегаем многократного срабатывания
      _loopCount++;
      if (_loopCount >= widget.ad.repeatCount) {
        _onContentFinished();
      } else {
        // Повторяем воспроизведение
        _videoController?.seekTo(Duration.zero).then((_) {
          _videoController?.play();
          _videoController?.addListener(_videoListener); // Восстанавливаем слушатель
        });
      }
    }
  }

  void _onContentFinished() {
    if (mounted) {
      context.read<AdDisplayBloc>().add(ShowNextAd());
    }
  }

  void _disposeControllers() {
    _imageTimer?.cancel();
    final controller = _videoController;
    if (controller != null) {
      controller.removeListener(_videoListener);
      controller.dispose();
    }
    _videoController = null;

    // Очень важно освободить созданный Blob URL, чтобы избежать утечек памяти в браузере
    if (_videoObjectUrl != null) {
      html.Url.revokeObjectUrl(_videoObjectUrl!);
      _videoObjectUrl = null;
    }
    _loopCount = 0;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Отображаем изображение
    if (widget.ad.mediaType == 'image' && widget.ad.imageBytes != null) {
      return Image.memory(
        widget.ad.imageBytes!,
        key: ValueKey('img-${widget.ad.id}'),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // Отображаем видеоплеер
    if (widget.ad.mediaType == 'video' &&
        _videoController != null &&
        _videoController!.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    }

    // Показываем индикатор загрузки, пока контент инициализируется
    return const Center(child: CircularProgressIndicator());
  }
}