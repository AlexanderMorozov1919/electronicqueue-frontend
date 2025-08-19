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
  Timer? _refreshTimer;
  String? _currentScreen;

  // Реклама будет обновляться с сервера каждые 5 минут
  static const _refreshInterval = Duration(minutes: 5);

  AdDisplayBloc({required this.repository}) : super(const AdDisplayState()) {
    on<FetchEnabledAds>(_onFetchEnabledAds);
    on<ShowNextAd>(_onShowNextAd);
  }

  Future<void> _onFetchEnabledAds(
      FetchEnabledAds event, Emitter<AdDisplayState> emit) async {
    // Если screen еще не установлен, или изменился, или это принудительное обновление
    if (_currentScreen == null ||
        _currentScreen != event.screen ||
        event.isForced) {
      _currentScreen = event.screen;
      _refreshTimer?.cancel();

      try {
        final newAds = await repository.getEnabledAds(event.screen);

        // Сравниваем списки по ID, чтобы избежать ненужной перерисовки
        final oldAdIds = state.ads.map((ad) => ad.id).toList();
        final newAdIds = newAds.map((ad) => ad.id).toList();

        if (!listEquals(oldAdIds, newAdIds)) {
          emit(AdDisplayState(ads: newAds, currentIndex: 0));
        } else if (newAds.isEmpty && state.ads.isNotEmpty) {
          emit(const AdDisplayState(ads: [], currentIndex: 0));
        }
      } catch (e) {
        print("Failed to fetch ads: $e");
        // В случае ошибки, очищаем список, чтобы не показывать устаревшую рекламу
        emit(const AdDisplayState(ads: [], currentIndex: 0));
      } finally {
        // Перезапускаем таймер обновления в любом случае
        _startRefreshTimer();
      }
    }
  }

  void _onShowNextAd(ShowNextAd event, Emitter<AdDisplayState> emit) {
    if (state.ads.isEmpty) return;

    // Просто переходим к следующему элементу по кругу
    final nextIndex = (state.currentIndex + 1) % state.ads.length;
    emit(state.copyWith(currentIndex: nextIndex));
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
      if (!isClosed && _currentScreen != null) {
        // Добавляем принудительное обновление
        add(FetchEnabledAds(screen: _currentScreen!, isForced: true));
      }
    });
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}