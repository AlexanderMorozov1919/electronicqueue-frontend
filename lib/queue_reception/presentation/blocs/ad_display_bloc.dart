import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:elqueue/queue_reception/domain/entities/ad_display.dart';
import 'package:elqueue/queue_reception/domain/repositories/ad_display_repository.dart';
import 'package:equatable/equatable.dart';

part 'ad_display_event.dart';
part 'ad_display_state.dart';

class AdDisplayBloc extends Bloc<AdDisplayEvent, AdDisplayState> {
  final AdDisplayRepository repository;
  Timer? _adTimer;
  Timer? _refreshTimer;

  AdDisplayBloc({required this.repository}) : super(const AdDisplayState()) {
    on<FetchEnabledAds>(_onFetchEnabledAds);
    on<_ShowNextAd>(_onShowNextAd);

    // Убрали периодическое обновление, так как оно теперь происходит после каждого цикла
    // _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
    //   add(FetchEnabledAds());
    // });
  }

  Future<void> _onFetchEnabledAds(FetchEnabledAds event, Emitter<AdDisplayState> emit) async {
    // Небольшая задержка перед запросом, чтобы избежать "дергания" при быстром цикле
    await Future.delayed(const Duration(milliseconds: 200)); 
    final ads = await repository.getEnabledAds();
    _adTimer?.cancel();
    if (ads.isNotEmpty) {
      emit(state.copyWith(ads: ads, currentIndex: 0));
      _startAdCycle();
    } else {
      emit(state.copyWith(ads: [], currentIndex: 0));
    }
  }

  void _onShowNextAd(_ShowNextAd event, Emitter<AdDisplayState> emit) {
    if (state.ads.isEmpty) return;
    
    // ИЗМЕНЕНО: Логика обновления после цикла
    final nextIndex = (state.currentIndex + 1) % state.ads.length;

    if (nextIndex == 0) {
      // Цикл завершен, запрашиваем обновленные данные
      add(FetchEnabledAds());
    } else {
      // Просто показываем следующий слайд
      emit(state.copyWith(currentIndex: nextIndex));
      _startAdCycle();
    }
  }

  void _startAdCycle() {
    _adTimer?.cancel();
    if (state.ads.isEmpty) return;

    final currentAd = state.ads[state.currentIndex];
    _adTimer = Timer(Duration(seconds: currentAd.durationSec), () {
      add(_ShowNextAd());
    });
  }

  @override
  Future<void> close() {
    _adTimer?.cancel();
    _refreshTimer?.cancel();
    return super.close();
  }
}