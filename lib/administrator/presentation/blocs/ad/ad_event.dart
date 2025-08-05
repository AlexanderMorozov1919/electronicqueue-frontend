part of 'ad_bloc.dart';

abstract class AdEvent extends Equatable {
  const AdEvent();
  @override
  List<Object> get props => [];
}

class LoadAds extends AdEvent {}

class AddAd extends AdEvent {
  final AdEntity ad;
  const AddAd(this.ad);
  @override
  List<Object> get props => [ad];
}

class UpdateAdInfo extends AdEvent {
  final AdEntity ad;
  const UpdateAdInfo(this.ad);
  @override
  List<Object> get props => [ad];
}

class DeleteAdById extends AdEvent {
  final int id;
  const DeleteAdById(this.id);
  @override
  List<Object> get props => [id];
}