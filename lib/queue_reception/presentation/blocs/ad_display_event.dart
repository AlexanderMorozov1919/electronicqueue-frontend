part of 'ad_display_bloc.dart';

abstract class AdDisplayEvent extends Equatable {
  const AdDisplayEvent();
  @override
  List<Object> get props => [];
}

class FetchEnabledAds extends AdDisplayEvent {
  final String screen;
  final bool isForced; // Флаг для принудительного обновления

  const FetchEnabledAds({required this.screen, this.isForced = false});

  @override
  List<Object> get props => [screen, isForced];
}

class ShowNextAd extends AdDisplayEvent {}