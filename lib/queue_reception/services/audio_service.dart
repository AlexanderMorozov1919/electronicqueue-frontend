import 'dart:async';
import 'dart:collection';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import '../../config/app_config.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final Queue<AnnouncementRequest> _announcementQueue = Queue();
  bool _isPlaying = false;
  bool _isUserInteracted = false;

  // Для отслеживания последнего вызванного талона
  String? _lastCalledTicket;

  // Флаг, который показывает, отключен ли звук пользователем.
  bool _isMuted = true;
  // Notifier для уведомления UI об изменениях состояния звука.
  final ValueNotifier<bool> isMutedNotifier = ValueNotifier(true);

  void setUserInteracted() {
    _isUserInteracted = true;
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    isMutedNotifier.value = _isMuted;
    print('AudioService: Sound muted status toggled to: $_isMuted');
    // Если звук был выключен, но в очереди есть запросы, попробуем обработать
    if (!_isMuted && !_isPlaying && _announcementQueue.isNotEmpty) _processQueue();
  }

  Future<void> announceTicket(String ticketNumber, String windowNumber) async {
    // Проверяем, не является ли это повторным вызовом того же талона
    if (_lastCalledTicket == ticketNumber) {
      print('AudioService: Skipping duplicate announcement for ticket $ticketNumber');
      return;
    }

    final request = AnnouncementRequest(
      ticketNumber: ticketNumber,
      windowNumber: windowNumber,
    );

    _announcementQueue.add(request);
    _lastCalledTicket = ticketNumber;
    
    print('AudioService: Added announcement to queue: $ticketNumber -> window $windowNumber');
    
    if (!_isPlaying) {
      await _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_announcementQueue.isEmpty) {
      _isPlaying = false;
      return;
    }

    _isPlaying = true;
    final request = _announcementQueue.removeFirst();

    try {
      await _playAnnouncement(request);
    } catch (e) {
      print('AudioService: Error playing announcement: $e');
    }

    // Обрабатываем следующий элемент в очереди
    await _processQueue();
  }

  Future<void> _playAnnouncement(AnnouncementRequest request) async {
    // Проверяем, что пользователь взаимодействовал с экраном И звук не выключен
    if (!_isUserInteracted || _isMuted) {
      print('AudioService: User interaction required for autoplay or sound is muted.');
      return;
    }

    // Создаем новый экземпляр AudioPlayer для каждого воспроизведения
    final audioPlayer = AudioPlayer();
    
    try {
      final audioUrl = '${AppConfig.apiBaseUrl}/api/audio/announce?ticket=${request.ticketNumber}&window=${request.windowNumber}';
      
      print('AudioService: Loading audio from: $audioUrl');
      
      // ================================================================
      // ИЗМЕНЕНИЕ: Используем более надежный метод загрузки
      // Сначала создаем источник аудио
      final source = AudioSource.uri(Uri.parse(audioUrl));

      // Затем загружаем его. Метод `setAudioSource` завершается (Future), 
      // когда аудио готово к воспроизведению. Это решает проблему с обрезкой.
      await audioPlayer.setAudioSource(source);
      
      // Теперь, когда аудио загружено, можно безопасно его воспроизводить
      audioPlayer.play();
      // ================================================================
      
      // Ждем завершения воспроизведения
      await audioPlayer.playerStateStream
          .firstWhere((state) => state.processingState == ProcessingState.completed);
      
      print('AudioService: Finished playing announcement for ${request.ticketNumber}');
      
    } catch (e) {
      print('AudioService: Error playing announcement: $e');
      
      // В случае ошибки, пробуем воспроизвести резервный звук
      await _playFallbackSound(audioPlayer);
    } finally {
      // Обязательно освобождаем ресурсы
      await audioPlayer.dispose();
    }
  }

  Future<void> _playFallbackSound(AudioPlayer audioPlayer) async {
    try {
      // Используем `setAsset` для локальных файлов
      await audioPlayer.setAsset('assets/audio/silent.mp3');
      await audioPlayer.play();
    } catch (e) {
      print('AudioService: Error playing fallback sound: $e');
    }
  }

  void clearLastCalledTicket() {
    _lastCalledTicket = null;
  }

  void dispose() {
    // Очищаем очередь
    _announcementQueue.clear();
    _isPlaying = false;
    _lastCalledTicket = null;
    isMutedNotifier.dispose();
  }
}

class AnnouncementRequest {
  final String ticketNumber;
  final String windowNumber;

  AnnouncementRequest({
    required this.ticketNumber,
    required this.windowNumber,
  });

  @override
  String toString() => 'AnnouncementRequest(ticket: $ticketNumber, window: $windowNumber)';
}