import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:elqueue/administrator/domain/entities/ad_entity.dart';
import 'package:elqueue/administrator/domain/usecases/manage_ads.dart';
import 'package:equatable/equatable.dart';

part 'ad_event.dart';
part 'ad_state.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  final GetAds getAds;
  final CreateAd createAd;
  final UpdateAd updateAd;
  final DeleteAd deleteAd;

  AdBloc({
    required this.getAds,
    required this.createAd,
    required this.updateAd,
    required this.deleteAd,
  }) : super(AdInitial()) {
    on<LoadAds>(_onLoadAds);
    on<AddAd>(_onAddAd);
    on<UpdateAdInfo>(_onUpdateAdInfo);
    on<DeleteAdById>(_onDeleteAdById);
  }

  Future<void> _onLoadAds(LoadAds event, Emitter<AdState> emit) async {
    emit(AdLoading());
    final result = await getAds();
    result.fold(
      (failure) => emit(AdError(failure.message)),
      (ads) => emit(AdLoaded(ads)),
    );
  }

  Future<void> _onAddAd(AddAd event, Emitter<AdState> emit) async {
    final result = await createAd(event.ad);
    result.fold(
      (failure) => emit(AdError(failure.message)),
      (_) => add(LoadAds()),
    );
  }

  Future<void> _onUpdateAdInfo(UpdateAdInfo event, Emitter<AdState> emit) async {
    final result = await updateAd(event.ad);
    result.fold(
      (failure) => emit(AdError(failure.message)),
      (_) {
        if (state is AdLoaded) {
          final currentState = state as AdLoaded;
          final updatedAds = currentState.ads.map((ad) {
            return ad.id == event.ad.id ? event.ad : ad;
          }).toList();
          emit(AdLoaded(updatedAds));
        }
      },
    );
  }

  Future<void> _onDeleteAdById(DeleteAdById event, Emitter<AdState> emit) async {
    final result = await deleteAd(event.id);
    result.fold(
      (failure) => emit(AdError(failure.message)),
      (_) => add(LoadAds()),
    );
  }
}