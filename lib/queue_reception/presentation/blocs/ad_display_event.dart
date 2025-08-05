part of 'ad_display_bloc.dart';

abstract class AdDisplayEvent extends Equatable {
  const AdDisplayEvent();
  @override
  List<Object> get props => [];
}

class FetchEnabledAds extends AdDisplayEvent {}
class _ShowNextAd extends AdDisplayEvent {} // Внутреннее событие