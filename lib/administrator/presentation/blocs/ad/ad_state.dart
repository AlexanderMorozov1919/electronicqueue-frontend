part of 'ad_bloc.dart';

abstract class AdState extends Equatable {
  const AdState();
  @override
  List<Object> get props => [];
}

class AdInitial extends AdState {}
class AdLoading extends AdState {}

class AdLoaded extends AdState {
  final List<AdEntity> ads;
  const AdLoaded(this.ads);
  @override
  List<Object> get props => [ads];
}

class AdError extends AdState {
  final String message;
  const AdError(this.message);
  @override
  List<Object> get props => [message];
}