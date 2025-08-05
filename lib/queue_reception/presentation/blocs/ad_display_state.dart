part of 'ad_display_bloc.dart';

class AdDisplayState extends Equatable {
  final List<AdDisplay> ads;
  final int currentIndex;

  const AdDisplayState({
    this.ads = const [],
    this.currentIndex = 0,
  });

  AdDisplayState copyWith({
    List<AdDisplay>? ads,
    int? currentIndex,
  }) {
    return AdDisplayState(
      ads: ads ?? this.ads,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object> get props => [ads, currentIndex];
}