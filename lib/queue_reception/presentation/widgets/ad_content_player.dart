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
    if (oldWidget.ad.id != widget.ad.id) {
      _disposeControllers();
      _initializeContent();
    }
  }

  void _initializeContent() {
    if (widget.ad.mediaType == 'image' && widget.ad.imageBytes != null) {
      // Используем durationSec из виджета, со значением по умолчанию 5 секунд
      final duration = widget.ad.durationSec ?? 5;
      _imageTimer = Timer(Duration(seconds: duration), _onContentFinished);
    } else if (widget.ad.mediaType == 'video' && widget.ad.videoBytes != null) {
      if (kIsWeb) {
        final blob = html.Blob([widget.ad.videoBytes!], 'video/mp4');
        _videoObjectUrl = html.Url.createObjectUrlFromBlob(blob);

        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(_videoObjectUrl!))
              ..initialize().then((_) {
                if (!mounted) return;
                setState(() {});
                _videoController?.setVolume(0);
                _videoController?.play();
                _videoController?.addListener(_videoListener);
              });
      } else {
        print(
            "Video playback from memory is only supported on the web platform.");
      }
    }
  }

  void _videoListener() {
    if (!mounted ||
        _videoController == null ||
        !_videoController!.value.isInitialized) return;

    final position = _videoController!.value.position;
    final duration = _videoController!.value.duration;

    if (position > Duration.zero && position >= duration) {
      _videoController!.removeListener(_videoListener);
      _loopCount++;
      // Используем repeatCount из виджета, со значением по умолчанию 1
      final repeatCount = widget.ad.repeatCount ?? 1;
      if (_loopCount >= repeatCount) {
        _onContentFinished();
      } else {
        _videoController?.seekTo(Duration.zero).then((_) {
          _videoController?.play();
          _videoController?.addListener(_videoListener);
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
    if (widget.ad.mediaType == 'image' && widget.ad.imageBytes != null) {
      return Image.memory(
        widget.ad.imageBytes!,
        key: ValueKey('img-${widget.ad.id}'),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

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

    return const Center(child: CircularProgressIndicator());
  }
}