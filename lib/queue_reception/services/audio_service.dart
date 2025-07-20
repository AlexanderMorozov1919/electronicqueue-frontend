import 'dart:async';
import 'dart:collection';
import 'package:just_audio/just_audio.dart';
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

  void setUserInteracted() {
    _isUserInteracted = true;
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
    if (!_isUserInteracted) {
      print('AudioService: User interaction required for autoplay');
      return;
    }

    // Создаем новый экземпляр AudioPlayer для каждого воспроизведения
    final audioPlayer = AudioPlayer();
    
    try {
      final audioUrl = '${AppConfig.apiBaseUrl}/api/audio/announce?ticket=${request.ticketNumber}&window=${request.windowNumber}';
      
      print('AudioService: Loading audio from: $audioUrl');
      
      // Устанавливаем источник аудио
      await audioPlayer.setUrl(audioUrl);
      
      // Воспроизводим
      await audioPlayer.play();
      
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