part of 'ad_display_bloc.dart';

abstract class AdDisplayEvent extends Equatable {
  const AdDisplayEvent();
  @override
  List<Object> get props => [];
}

class FetchEnabledAds extends AdDisplayEvent {
  final String screen;
  const FetchEnabledAds({required this.screen});

  @override
  List<Object> get props => [screen];
}

class ShowNextAd extends AdDisplayEvent {}