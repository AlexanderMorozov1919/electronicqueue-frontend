import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:elqueue/queue_reception/domain/entities/ad_display.dart';
import 'package:elqueue/queue_reception/domain/repositories/ad_display_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'ad_display_event.dart';
part 'ad_display_state.dart';

class AdDisplayBloc extends Bloc<AdDisplayEvent, AdDisplayState> {
  final AdDisplayRepository repository;
  Timer? _adTimer;
  Timer? _refreshTimer;
  String? _currentScreen;

  static const _refreshInterval = Duration(seconds: 5);

  AdDisplayBloc({required this.repository}) : super(const AdDisplayState()) {
    on<FetchEnabledAds>(_onFetchEnabledAds);
    on<ShowNextAd>(_onShowNextAd);
  }

  Future<void> _onFetchEnabledAds(FetchEnabledAds event, Emitter<AdDisplayState> emit) async {
    _currentScreen = event.screen;
    _adTimer?.cancel();
    _refreshTimer?.cancel();

    final newAds = await repository.getEnabledAds(event.screen);

    // Если новый список пуст
    if (newAds.isEmpty) {
      // Если и старый был пуст, ничего не делаем, просто ждем следующего вызова таймера
      if (state.ads.isNotEmpty) {
        emit(state.copyWith(ads: [], currentIndex: 0));
      }
      _startRefreshTimer();
      return;
    }

    // Если новый список не пуст, а старый был пуст, или если списки отличаются
    if (!listEquals(newAds, state.ads)) {
      emit(state.copyWith(ads: newAds, currentIndex: 0));
    } 
    // Если списки одинаковые, мы не генерируем новое состояние, чтобы избежать моргания.
    // Цикл будет перезапущен из _onShowNextAd.
    
    _startAdCycle();
  }

  void _onShowNextAd(ShowNextAd event, Emitter<AdDisplayState> emit) {
    if (state.ads.isEmpty || _currentScreen == null) return;

    final nextIndex = state.currentIndex + 1;

    // КЛЮЧЕВОЕ ИЗМЕНЕНИЕ: Логика зацикливания
    if (nextIndex >= state.ads.length) {
      // Цикл завершен.
      // 1. Проверяем, не изменился ли список рекламы на сервере.
      add(FetchEnabledAds(screen: _currentScreen!));
      // 2. Оптимистично сбрасываем индекс на 0, чтобы цикл продолжился немедленно,
      //    даже если список на сервере не изменился.
      //    Новая логика в _onFetchEnabledAds предотвратит моргание.
      emit(state.copyWith(currentIndex: 0));
    } else {
      // Просто показываем следующий слайд
      emit(state.copyWith(currentIndex: nextIndex));
      _startAdCycle();
    }
  }

  void _startAdCycle() {
    _adTimer?.cancel();
    if (state.ads.isEmpty) return;

    // Убедимся, что индекс в пределах допустимого диапазона
    final index = state.currentIndex.clamp(0, state.ads.length - 1);
    final currentAd = state.ads[index];
    
    // Логика таймера для изображений перенесена в AdContentPlayer
    // Здесь мы просто инициируем показ, а виджет сам сообщит, когда закончит
    // Этот метод теперь нужен только для первоначального запуска после загрузки
    if (currentAd.mediaType != 'image') {
       // Для видео таймер не нужен, виджет сам переключит
       return;
    }

    _adTimer = Timer(Duration(seconds: currentAd.durationSec), () {
      if (!isClosed) add(ShowNextAd());
    });
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(_refreshInterval, () {
      if (!isClosed && _currentScreen != null) {
        add(FetchEnabledAds(screen: _currentScreen!));
      }
    });
  }

  @override
  Future<void> close() {
    _adTimer?.cancel();
    _refreshTimer?.cancel();
    return super.close();
  }
}